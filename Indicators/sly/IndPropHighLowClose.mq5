//+------------------------------------------------------------------+
//|                                          IndPropHighLowClose.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2

// High-low histogram rendering settings (change index 0 to 1 in the directive)
#property indicator_type1 DRAW_HISTOGRAM2
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrBlue
#property indicator_width1 5
#property indicator_label1 "High;Low"

// close line drawing setting (change index 1 to 2 in the directive)
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_color2 clrRed
#property indicator_width2 2
#property indicator_label2 "Close"

double highs[];
double lows[];
double closes[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
// arrays for buffers for 3 price type
  SetIndexBuffer(0, highs);
  SetIndexBuffer(1, lows);
  SetIndexBuffer(2, closes);

//---
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
 {
// on each new bar or set of bars (including the first calculation)
  if(prev_calculated != rates_total)
   {
    // fill in all new bars
    ArrayCopy(highs, high, prev_calculated, prev_calculated);
    ArrayCopy(lows, low, prev_calculated, prev_calculated);
    ArrayCopy(closes, close, prev_calculated, prev_calculated);

   }
  else     // ticks on the current bar
   {
    // Update the last bar
    highs[rates_total - 1] = high[rates_total - 1];
    lows[rates_total - 1] = low[rates_total - 1];
    closes[rates_total - 1] = close[rates_total - 1];

   }

//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
