//+------------------------------------------------------------------+
//|                                                      UseWPR1.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_width1  1
#property indicator_label1  "WPR"

input int WPRPeriod = 14;
int handle;
double WPRBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  SetIndexBuffer(0, WPRBuffer);
// Passing name and parameter
  handle = iCustom(_Symbol, _Period, "IndWPR", WPRPeriod);
  return(handle == INVALID_HANDLE ? INIT_FAILED : INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
 {
// wait until the slave indicator is calculated on all bars
  if(BarsCalculated(handle) != rates_total)
   {
    return prev_calculated;
   }

// Copy the entire timeseries of the surbodinate indicator or
// on new bars to our buffer
  const int n = CopyBuffer(handle, 0, 0, rates_total - prev_calculated + 1, WPRBuffer);

//--- return value of prev_calculated for next call
  return(n > -1 ? rates_total : 0);
 }
//+------------------------------------------------------------------+
