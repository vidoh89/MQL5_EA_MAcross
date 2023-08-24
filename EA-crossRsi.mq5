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
input int rsi_period= 8;

//sl and tp inputs
input double sl_input=200;
input double tp_input=200;
input double lot_size= 0.02;



//---
//Inputs for swing high and low 
///
input char adx_Period = 8;
double adx_array[];
//Trail/sl/tp input
input double TslPoints = 100;

//
//HighLow sl tp
int barsTotal;

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
    
    
    //---------------------------------------------------------
    //Call handle for fast Ma fastMA
  static  int handleFastMa = iMA(_Symbol,PERIOD_CURRENT,MaPeriod,0,MODE_SMA,PRICE_CLOSE);
    //create array to store double values
    double fastArray[];
    //Create copyBuffer to store the fastMA values
    CopyBuffer(handleFastMa,0,1,2,fastArray);
    //Use ArraySetAsSeries to reverse Array index from left to right
    ArraySetAsSeries(fastArray,true);
    
    
    //Compare array index inputs--Check for fastSma to cross above slowSma
    if(OrdersTotal()==0 && PositionsTotal()==0)
    //if(handleFastMa>handleSlowMa && handleSlowMa<handlePriceEma)
    
    if(no_trade_func()=="Trades are live"&&adx_Func()=="Increase,Requirements met" && rsi_func()=="Bears_move" &&fastArray[0]>slowArray[0] && fastArray[1]>slowArray[1])
        //&& slowArray[0]>priceArray[0] && slowArray[1]>priceArray[1])
   
      {
      Print("Upper cross occurence");
      //Create variable to store ask price and place variable inside but function
      double ask =SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      //Create variable to hold sl information
      double sl = ask-sl_input *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
                  
      //Create variable for tp
      double tp = ask+ tp_input*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
       
     trade.Buy(lot_size,_Symbol,ask,sl,tp,"BuyTicket");
    }
      //Check for SMA crossing downwards
         if(OrdersTotal()==0 && PositionsTotal()==0) 
        if (no_trade_func()=="Trades are live"&&adx_Func()=="Increase,Requirements met" && rsi_func()=="Bulls_move" &&fastArray[0]<slowArray[0] && fastArray[1]<slowArray[1])
         // && slowArray[0]<priceArray[0] && slowArray[1]<priceArray[1])
       
         {
        Print("Lower cross occurence");
        //Create variable for bid data
        double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
        //Create sl variable
         double sl = bid +sl_input *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
        //Create tp variable
        double tp = bid - tp_input *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
               trade.Sell(lot_size,_Symbol,bid,sl_input,tp,"SellTicket");
        
       }
      }//close for the time and timestamp variable comp.   
         trailStop();
           //high_low_sl();
      Comment("\n","ADX_signal=",adx_Func(),"\n","Balance=>",accInfo,"\n","Rsi_conditions==>",rsi_func(),"\n","Day_trade_status",no_trade_func());
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
    else if(adx_array[1]>=50){
    
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
   int rsi_handle= iRSI(_Symbol,PERIOD_CURRENT,rsi_period,PRICE_CLOSE);
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
///high low sl
void high_low_sl(){
//int bars = iBars(_Symbol,PERIOD_CURRENT);
 
 //if(barsTotal !=bars){
 //barsTotal = bars;
 //Print(bars,"",barsTotal);
 
 for(int i = PositionsTotal()-1;i >=0;i--){
         
         ulong posTicket = PositionGetTicket(i);
         if(PositionSelectByTicket(posTicket)){
         double poss1 = PositionGetDouble(POSITION_SL);
         double posTp = PositionGetDouble(POSITION_TP);
          
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
            int shift = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,10,1);
            double low = iLow(_Symbol,PERIOD_CURRENT,shift);
            low = NormalizeDouble(low,_Digits);
            
            if(low>poss1){
            
            
            
            if(trade.PositionModify(posTicket,low,posTp)){
            Print(__FUNCTION__,">Pos #",posTicket,"was modified");
            }
            
            }
          
          
          }
          
          else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
           int shift = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,10,1);
            double high = iHigh(_Symbol,PERIOD_CURRENT,shift);
            high = NormalizeDouble(high,_Digits);
            
                  if(high<poss1 ||poss1==0 ){
            
                      
            
            if(trade.PositionModify(posTicket,high,posTp)){
                     Print(__FUNCTION__,">Pos #",posTicket,"was modified");
                  }
            
               }
          
            }   
         
         }
      
      }
   //}
}

string no_trade_func(){
MqlDateTime structTime;
TimeCurrent(structTime);
int friday = structTime.day;
string signal="";
if(friday==5){
 signal = "No trades on Friday"; 
}
else signal ="Trades are live";

return signal; 
}