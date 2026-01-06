//+------------------------------------------------------------------+
//|                                                     customMA.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_label1 "sly-MA"
#property indicator_color1 clrDodgerBlue

input int rsiPeriod = 21;
input int maPeriod = 21;

int maHandle;
int rsiHandle;

double RSImaBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
  SetIndexBuffer(0, RSImaBuffer);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, maPeriod - 1);
  IndicatorSetString(INDICATOR_SHORTNAME, "rsaMa" + "(" + (string)maPeriod + ")");

  rsiHandle = iRSI(_Symbol, _Period, rsiPeriod, PRICE_WEIGHTED);
  maHandle = iMA(_Symbol, _Period, maPeriod, 0, MODE_LWMA, rsiHandle);

  return(rsiHandle == INVALID_HANDLE
         && maHandle == INVALID_HANDLE ? INIT_FAILED : INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
//---
  if(BarsCalculated(maHandle) != rates_total) {
    return prev_calculated;
  }

  const int n = CopyBuffer(maHandle, 0, 0, rates_total - prev_calculated + 1, RSImaBuffer);

//--- return value of prev_calculated for next call
  return(n > -1 ? rates_total : 0);
}
//+------------------------------------------------------------------+
