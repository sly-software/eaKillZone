//+------------------------------------------------------------------+
//|                                                       UseHma.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1 "Buy"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrGold
#property indicator_label2 "Sell"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrCrimson

//#include <stdlib.mqh>

enum enPrices {
  pr_close,      // Close
  pr_open,       // Open
  pr_high,       // High
  pr_low,        // Low
  pr_median,     // Median
  pr_typical,    // Typical
  pr_weighted,   // Weighted
  pr_average     // Average (high+low+oprn+close)/4
};

input int HmaLength = 21;    // Hull period
input int HmaPower  = 3;    // Hull power
input enPrices Price = pr_close; // Price
bool applyRSIfilter = false;

int Offset = 1;
int rsiPeriod = HmaLength;
int maPeriod = HmaLength;
int ArrowShift = 500;
int hmaHandle;
int rsiHandle;
int maRsiHandle;

double UpBuffer[];
double DownBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
  EventSetMillisecondTimer(10 * 1000);

  SetIndexBuffer(0, UpBuffer);
  SetIndexBuffer(1, DownBuffer);

  ArraySetAsSeries(UpBuffer, true);
  ArraySetAsSeries(DownBuffer, true);



// up and down arrow character codes
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);

  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  hmaHandle = iCustom(_Symbol, _Period, "sly/hull_", HmaLength, HmaPower, Price);
  rsiHandle = iRSI(_Symbol, _Period, rsiPeriod, PRICE_WEIGHTED);
  maRsiHandle = iMA(_Symbol, _Period, maPeriod, 0, MODE_LWMA, rsiHandle);

  return hmaHandle == INVALID_HANDLE ? INIT_FAILED : INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  IndicatorRelease(hmaHandle);
  EventKillTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
  ChartRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {

  if(BarsCalculated(hmaHandle) != rates_total) {
    return prev_calculated;
  }

  if(prev_calculated == 0) {
    ArrayInitialize(UpBuffer, EMPTY_VALUE);
    ArrayInitialize(DownBuffer, EMPTY_VALUE);

    for(int i = prev_calculated; i < rates_total - 2; i++) {
      MarkSignal(i, low, high, open);
    }
  }

  if(prev_calculated != rates_total) {
  
    UpBuffer[0]=EMPTY_VALUE;
    DownBuffer[0]=EMPTY_VALUE;
    
    MarkSignal(0, low, high, open);
  }
  return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| MARK SIGNAL: custom function to generate signal                  |
//+------------------------------------------------------------------+
void MarkSignal(const int bar,
                const double &low[],
                const double &high[],
                const double &open[]) {

  double ma[1], rsi[2], hull[3];

  if(!(ArrayGetAsSeries(low)
       && ArrayGetAsSeries(high)
       && ArrayGetAsSeries(open))) {

    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(open, true);
  }

  if(CopyBuffer(hmaHandle, 0, bar, 3, hull) == 3
      && CopyBuffer(rsiHandle, 0, bar, 2, rsi) == 2
      && CopyBuffer(maRsiHandle, 0, bar, 1, ma) == 1) {

    // buy signal
    if((hull[2] > hull[1] && hull[1] <= hull[0])
        && (rsi[0] < ma[0] && rsi[1] > ma[0])) {
      UpBuffer[bar] = low[bar] - (_Point * ArrowShift);

    } else {
      UpBuffer[bar] = EMPTY_VALUE;
    }

    if((hull[2] < hull[1] && hull[1] >= hull[0]) // sell signal
        &&  (rsi[0] > ma[0] && rsi[1] < ma[0])) {
      DownBuffer[bar] = high[bar] + (_Point * ArrowShift);
    } else {
      DownBuffer[bar] = EMPTY_VALUE;
    }
  } else {
    Print("MARKSIGNAL: Failed to copy buffer from handles ",  GetLastError() );
    return;;
  }
}
//+------------------------------------------------------------------+
