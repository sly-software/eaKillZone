//+------------------------------------------------------------------+
//|                                               UseWPRFractals.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers   3
#property indicator_plots     3
// buffer drawing settings
#property indicator_type1     DRAW_ARROW
#property indicator_color1    clrMagenta
#property indicator_width1    1
#property indicator_label1    "Sell"
#property indicator_type2     DRAW_ARROW
#property indicator_color2    clrSilver
#property indicator_width2    1
#property indicator_label2    "Buy"
#property indicator_type3     DRAW_NONE
#property indicator_color3    clrGreen
#property indicator_width3    1
#property indicator_label3    "Filter"

input int PeriodWPR = 11;
input int PeriodEMA = 5;
input int FractalOrder = 1;
input int Offset = 0;
input double Threshold = 0.2;


// upper signal means overbought, i.e. selling
double UpBuffer[];
// lower signal means oversold, i.e. buy
double DownBuffer[];
// fractals filter direction +1(up/buy), -1 (down/sell)
double Filter[];
int handleWPR, handleEMA3, handleFractals;
const int ArrowShift = 60;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
  SetIndexBuffer(0, UpBuffer);
  SetIndexBuffer(1, DownBuffer);
  SetIndexBuffer(2, Filter, INDICATOR_DATA); // version: INDICATOR_CALCULATIONS

  ArraySetAsSeries(UpBuffer, true);
  ArraySetAsSeries(DownBuffer, true);
  ArraySetAsSeries(Filter, true);

// arrow signals
  PlotIndexSetInteger(0, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW, 233);

// padding for arrow
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -ArrowShift);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, +ArrowShift);

// subordinate indicators
  handleWPR = iCustom(_Symbol, _Period, "IndWPR", PeriodWPR);
  handleEMA3 = iCustom(_Symbol, _Period, "IndTripleEMA", PeriodEMA, 0, handleWPR);
  handleFractals = iCustom(_Symbol, _Period, "IndFractals", FractalOrder);

  if(handleFractals == INVALID_HANDLE ||
      handleEMA3 == INVALID_HANDLE ||
      handleFractals == INVALID_HANDLE) {
    return INIT_FAILED;
  }

//---
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
//---
  if(BarsCalculated(handleEMA3) != rates_total || BarsCalculated(handleFractals) != rates_total) {
    return prev_calculated;
  }

  ArraySetAsSeries(price, true);

  if(prev_calculated == 0) { // first launch
    ArrayInitialize(UpBuffer, EMPTY_VALUE);
    ArrayInitialize(DownBuffer, EMPTY_VALUE);
    ArrayInitialize(Filter, 0);

    // look for signals throughout history
    for(int i = rates_total - FractalOrder - 1; i >= 0; --i) {
      MarkSignals(i, Offset, price);
    }
  } else { // online

    for(int i = 0; i < rates_total - prev_calculated; ++i) {
      UpBuffer[i] = EMPTY_VALUE;
      DownBuffer[i] = EMPTY_VALUE;
      Filter[i] = 0;
    }

    // looking for a signal on a new bar or each tick (if Offset == 0)
    if(rates_total != prev_calculated || Offset == 0) {
      MarkSignals(0, Offset, price);
    }
  }

//--- return value of prev_calculated for next call
  return(rates_total);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| CUSTOM FUNCTION                                                  |
//+------------------------------------------------------------------+
int MarkSignals(const int bar, const int offset, const double &price[]) {
  double wpr[2];
  double peaks[1], hollows[1];

//Print(CopyBuffer(handleFractals, 1, bar + offset + FractalOrder, 1, hollows));

  if(CopyBuffer(handleEMA3, 0, bar + offset, 2, wpr) == 2
      && CopyBuffer(handleFractals, 0, bar + offset + FractalOrder, 1, peaks) == 1
      && CopyBuffer(handleFractals, 1, bar + offset + FractalOrder, 1, hollows) == 1) {


    int filterdirection = (int)Filter[bar + 1];

    // the last fractal set the reversal movement
    if(peaks[0] != EMPTY_VALUE) {
      filterdirection = -1; //sell
    }

    if(hollows[0] != EMPTY_VALUE) {
      filterdirection = +1; // buy
    }

    Filter[bar] = filterdirection; // remember the current direction

    // translate 2 WPR values into the range [-1, +1]
    const double old = (wpr[0] + 50) / 50;  // +1.0  -1.0
    const double last = (wpr[1] + 50) / 50; // +1.0  -1.0



    // bounce from the top -> down
    if(filterdirection == -1
        && old >= 1.0 - Threshold
        && last <= 1.0 - Threshold) {
      UpBuffer[bar] = price[bar];
      return -1; // sale
    }

    // bounce from the bottom -> up
    if(filterdirection == +1
        && old <= -1.0 + Threshold
        && last >= -1.0 + Threshold) {

      DownBuffer[bar] = price[bar];
      return +1; // purchase
    }
  }
  return 0; // no signal
}
//+------------------------------------------------------------------+
