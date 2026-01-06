//+------------------------------------------------------------------+
//|                                                  IndReplica1.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

input ENUM_DRAW_TYPE DrawType = DRAW_LINE;
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;

//#include <MQLBook/PRTF.mqh>

//--- GLOBAL VARIABLES
double buffer[]; // Global dynamic array
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
// register an array as an indicator buffer
  Print(SetIndexBuffer(0, buffer)); // true /ok
// the second incorect call is made here intentionally to show an error
  Print(SetIndexBuffer(1, buffer)); // false / BUFFERS_WRONG_INDEX()
// check size: still o
  Print(ArraySize(buffer)); // 0

// Set the property of the chart numbered 0
  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DrawType);
  PlotIndexGetInteger(0, PLOT_LINE_STYLE, LineStyle);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);
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
// after starting, check that the platform automatically manages the size of the array
  if(prev_calculated == 0)
   {
    Print(ArraySize(buffer)); // 1019 - actual number of bars
   }

// on each new bar or set of bars (including the first calculation)
  if(prev_calculated != rates_total)
   {
    // fill in all new bars
    ArrayCopy(buffer, price, prev_calculated, prev_calculated);
   }
  else // ticks on the current bar
   {
    // update the last bar
    buffer[rates_total - 1] = price[rates_total - 1];
   }

//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
