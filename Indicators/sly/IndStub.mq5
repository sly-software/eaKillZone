//+------------------------------------------------------------------+
//|                                                      IndStub.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping

//---
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
 {
//---
  static int count = 0;
  ++count;

// compare the number of bars on the previous call and the current one
  if(prev_calculated != rates_total)
   {
    // Signal only if there is a difference
    PrintFormat("calculated=%d rates=%d; %d ticks", prev_calculated, rates_total, count);
   }

//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
