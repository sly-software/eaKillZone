//+------------------------------------------------------------------+
//|                                                       IndWPR.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_maximum 0.0
#property indicator_minimum -100.0

// Indictor display directives
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDodgerBlue

// Horizontal lines for over/bought/sell
#property indicator_level1 -20.0
#property indicator_level2 -80.0
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrSilver
#property indicator_levelwidth 1

// Input variable for setting WPR calculation period
input int WPRPeriod = 14;

// Buffer arr
double WPRBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
 {
//--- indicator buffers mapping

// Check for correct input
  if(WPRPeriod < 1)
   {
    Alert(StringFormat("Incorrect Period value (%d). Should be 1 or larger", WPRPeriod));
   }

// buffer binding
  SetIndexBuffer(0, WPRBuffer);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);
  IndicatorSetString(INDICATOR_SHORTNAME, "%R" + "(" + (string)WPRPeriod + ")");
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, WPRPeriod - 1);
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
//---
// If there isnt enough data/period too short
  if(rates_total < WPRPeriod || WPRPeriod < 1)
    return 0;

 /* if(prev_calculated == 0)
   {
    ArrayFill(WPRBuffer, 0, WPRPeriod - 1, EMPTY_VALUE);
    //ArrayInitialize(WPRBuffer, EMPTY_VALUE);
   }*/

  for(int i = fmax(prev_calculated - 1, WPRPeriod - 1); i < rates_total && !IsStopped(); i++)
   {
    double max_high = high[fmax(ArrayMaximum(high, i - WPRPeriod + 1, WPRPeriod), 0)];
    double min_low = low[fmax(ArrayMinimum(low, i - WPRPeriod + 1, WPRPeriod), 0)];

    if(max_high != min_low)
     {
      WPRBuffer[i] = -(max_high - close[i]) * 100 / (max_high - min_low);
     }
    else
     {
      WPRBuffer[i] = WPRBuffer[i - 1];
     }
   }


//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
