#property  copyright "Copyright 2023 . MetaQuotes Software Corp"
#property link "https://www.mql5.com"
#property version "1.00"
#include<Trade/Trade.mqh>
//


///MA inputs for trailing st/tp
//beta(currently not in use)
input ENUM_TIMEFRAMES TslMaTimeFrame = PERIOD_CURRENT;
input int MaPeriod =20;
input ENUM_MA_METHOD TslMaMethod = MODE_SMA;
input ENUM_APPLIED_PRICE TslMaAppPrice = PRICE_CLOSE;

///
input char adx_Period = 8;
double adx_array[];
//Trail/sl/tp input
input double TslPoints = 100;

//


//Create CTrade class which will access Trade.mqh properties
//Access class properties with double colons CTrade
//Save CTrade in variable trade.Access properties/functions with dot notation
// trade.property
CTrade trade;

int OnInit(void)
  {
   
   return(INIT_SUCCEEDED);
  }
  void OnDeinit(const int reason)
    {
   
    }
 void OnTick(void)
   {
   
   double accInfo = AccountInfoDouble(ACCOUNT_BALANCE);
   //Use control variable to control the number of times the code is ran
   //current structure will allow code to only run once per bar
   //datetime can store time variables 
   static datetime timeStamp;
   
   
   
   //Use another datetime variable to obtain time from each candle stored in 
   //Obtain the timeStamp variable.
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);//obtains timestamp of current candle
   
   //Check if time has changed so code can be ran
   if(timeStamp != time){
   timeStamp =time;//reset the timeStamp to the current cande time
   
   
   //By making the indicators static ,this saves on resources by only running code x*
     //Call handle for slow moving average
   static int handleSlowMa =  iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_SMA,PRICE_CLOSE);
    //Create an Array to store doulbe values
    double slowArray[];//This current array is a dynamic array 
    //CopyBuffer used to copy values from called indicator
    CopyBuffer(handleSlowMa,0,1,2,slowArray); 
    //Use ArraySetAsSeries to reverse the index count of the slowArray[]
    ArraySetAsSeries(slowArray,true);
    
    //Create ema to follow price closely
    
    static int handlePriceEma = iMA(_Symbol,PERIOD_CURRENT,5,0,MODE_SMA,PRICE_CLOSE);
    double priceArray[];
  
    
    CopyBuffer(handlePriceEma,0,1,2,priceArray);
    ArraySetAsSeries(priceArray,true);
    //---------------------------------------------------------
    //Call handle for fast Ma fastMA
  static  int handleFastMa = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);
    //create array to store double values
    double fastArray[];
    //Create copyBuffer to store the fastMA values
    CopyBuffer(handleFastMa,0,1,2,fastArray);
    //Use ArraySetAsSeries to reverse Array index from left to right
    ArraySetAsSeries(fastArray,true);
    
    
    //Compare array index inputs--Check for fastSma to cross above slowSma
    if(OrdersTotal()==0 && PositionsTotal()==0)
    //if(handleFastMa>handleSlowMa && handleSlowMa<handlePriceEma)
    
    if(adx_Func()=="Increase,Requirements met" && rsi_func()=="Bears_move" &&fastArray[0]>slowArray[0] && fastArray[1]>slowArray[1])
        //&& slowArray[0]>priceArray[0] && slowArray[1]>priceArray[1])
   
      {
      Print("Upper cross occurence");
      //Create variable to store ask price and place variable inside but function
      double ask =SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      //Create variable to hold sl information
      double sl = ask-100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      //Create variable for tp
      double tp = ask+ 100*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
       
     trade.Buy(0.01,_Symbol,ask,sl,tp,"BuyTicket");
    }
      //Check for SMA crossing downwards
         if(OrdersTotal()==0 && PositionsTotal()==0) 
        if (adx_Func()=="Increase,Requirements met" && rsi_func()=="Bulls_move" &&fastArray[0]<slowArray[0] && fastArray[1]<slowArray[1])
         // && slowArray[0]<priceArray[0] && slowArray[1]<priceArray[1])
       
         {
        Print("Lower cross occurence");
        //Create variable for bid data
        double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
        //Create sl variable
        double sl = bid +100 *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
        //Create tp variable
        double tp = bid - 100 *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
        trade.Sell(0.01,_Symbol,bid,sl,tp,"SellTicket");
        
       }
      }//close for the time and timestamp variable comp.   
         trailStop();
      
      Comment("\n","ADX_signal=",adx_Func(),"\n","Balance=>",accInfo,"\n","Rsi_conditions==>",rsi_func());
     }  
   
   string adx_Func(){
    string adx_signal = "";
    //adx indicator
    int adx_handle = iADX(_Symbol,PERIOD_CURRENT,adx_Period);
    CopyBuffer(adx_handle,0,0,20,adx_array);
    ArraySetAsSeries(adx_array,true);
    if(adx_array[1]<=20){
     adx_signal = "Not in range";
    
    }
    else if(adx_array[1]>=30){
    
    adx_signal="Increase,Requirements met";
    }
    else{
    adx_signal="Neutral";
    }
    return adx_signal;
   }
   
   void trailStop(){
   
   for(int i = PositionsTotal()-1; i>=0;i--){
   Print(i);
   ulong posTicket = PositionGetTicket(i);
   
   if(PositionSelectByTicket(posTicket)){
   
      if(PositionGetString(POSITION_SYMBOL)==_Symbol){
         double posSl = PositionGetDouble(POSITION_SL);
          double posTp = PositionGetDouble(POSITION_TP);
         
      Print(i,"->",posTicket,"",PositionGetString(POSITION_SYMBOL),"",_Symbol);
         
            
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
            double  sl= SymbolInfoDouble(_Symbol,SYMBOL_BID) -TslPoints *_Point;
            if(sl>posSl){
               CTrade trade_trail;
               
               if(trade_trail.PositionModify(posTicket,sl,posTp)){
               
                  Print(__FUNCTION__,">Pos#",posTicket,"was modfies...");
               }
            
            }
            
            
            }else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            
                double  sl= SymbolInfoDouble(_Symbol,SYMBOL_ASK) +TslPoints *_Point;
            if(sl<posSl || posSl==0){
               CTrade trade_trail;
               
               if(trade_trail.PositionModify(posTicket,sl,posTp)){
               
                  Print(__FUNCTION__,">Pos#",posTicket,"was modfies...");
                  
                 }
                 
               }
            
            }
         
         }
      }
   }
 }
 
 void IndHandle(){
 
  double handleMA = iMA(_Symbol,TslMaTimeFrame,MaPeriod,0,TslMaMethod,TslMaAppPrice);
 }

string rsi_func(){
   string rsi_signal = "";
   int rsi_handle= iRSI(_Symbol,PERIOD_CURRENT,4,PRICE_CLOSE);
   double rsi_array[];
   ArraySetAsSeries(rsi_array,true);
   CopyBuffer(rsi_handle,0,0,3,rsi_array);
   double rsi_value =NormalizeDouble(rsi_array[0],2);
   

   if(rsi_value>70){
   
      rsi_signal = "Bulls_move";
   }
  else if(rsi_value<30){
   
      rsi_signal="Bears_move";
   }
   else{rsi_signal="neutral";}
   return rsi_signal;

}