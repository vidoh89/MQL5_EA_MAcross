#property  copyright "Copyright 2023 . MetaQuotes Software Corp"
#property link "https://www.mql5.com"
#property version "1.00"
#include<Trade/Trade.mqh>



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
    
    if(fastArray[0]>slowArray[0] && fastArray[1]>slowArray[1])
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
        // if(fastArray[0]<slowArray[0] && fastArray[1]<slowArray[1]
         // && slowArray[0]<priceArray[0] && slowArray[1]<priceArray[1])
       
         {
        Print("Lower cross occurence");
        //Create variable for bid data
        double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
        //Create sl variable
        double sl = bid +100 *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
        //Create tp variable
        double tp = bid - 100 *SymbolInfoDouble(_Symbol,SYMBOL_POINT);
        //trade.Sell(0.01,_Symbol,bid,sl,tp,"SellTicket");
        
       }
      }//close for the time and timestamp variable comp.   
     }  
   