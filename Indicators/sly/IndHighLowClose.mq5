//+------------------------------------------------------------------+
//|                                              IndHighLowClose.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2

double highs[];
double lows[];
double closes[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
// arrays buffers for 3 price type
  SetIndexBuffer(0, highs);
  SetIndexBuffer(1, lows);
  SetIndexBuffer(2, closes);

// Drawing histogram between the High and Low candles under index 0
  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 5);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);

// drawing the line Close at index 1
  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);

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
if(prev_calculated != rates_total){
// fill in all new bars
ArrayCopy(highs, high, prev_calculated, prev_calculated);
ArrayCopy(lows, low, prev_calculated, prev_calculated);
ArrayCopy(closes, close, prev_calculated, prev_calculated);

} else { // ticks on the current bar
// Update the last bar
highs[rates_total - 1] = high[rates_total - 1];
lows[rates_total - 1] = low[rates_total - 1];
closes[rates_total - 1] = close[rates_total - 1];

}

//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
