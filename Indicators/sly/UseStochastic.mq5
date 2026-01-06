//+------------------------------------------------------------------+
//|                                                UseStochastic.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_label1 "St'Main"

#property indicator_type2 DRAW_LINE
#property indicator_color2 clrChocolate
#property indicator_width2 1
#property indicator_label2 "St'Signal"
#property indicator_style2 STYLE_DOT

// input varibales
input int KPeriod = 5;
input int DPeriod = 3;
input int Slowing = 3;
input ENUM_MA_METHOD Method = MODE_LWMA;
input ENUM_STO_PRICE StochasticPrice = STO_LOWHIGH;

// buffers
double MainBuffer[];
double SignalBuffer[];

int Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
  IndicatorSetString(INDICATOR_SHORTNAME,
                     StringFormat("Stochastic(%d, %d, %d)", KPeriod, DPeriod, Slowing));
//--- indicator buffers mapping
  SetIndexBuffer(0, MainBuffer);
  SetIndexBuffer(1, SignalBuffer);

// getting the descriptor Stochastic
  Handle = iStochastic(_Symbol, _Period, KPeriod, DPeriod, Slowing, Method, StochasticPrice);
//---
  return(Handle == INVALID_HANDLE ? INIT_FAILED : INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
 {
// waiting for the calculation of the stochastics on all bars
  if(BarsCalculated(Handle) != rates_total)
    return prev_calculated;

// copy data to our two buffers
  const int m = CopyBuffer(Handle, 0, 0, rates_total - prev_calculated + 1, MainBuffer);
  const int s = CopyBuffer(Handle, 1, 0, rates_total - prev_calculated + 1, SignalBuffer);

//--- return value of prev_calculated for next call
  return(s > -1 && m > -1 ? rates_total : 0);
 }
//+------------------------------------------------------------------+
