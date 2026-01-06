//+------------------------------------------------------------------+
//|                                                  IndFractals.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

// Rendering settings
//#property indicator_type1 DRAW_ZIGZAG
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
#property indicator_color1 clrCrimson
//#property indicator_color1 clrMediumOrchid
#property indicator_color2 clrLimeGreen
//#property indicator_width1 2
//#property indicator_label1 "ZigZag Up;ZigZag Down"
#property indicator_label1 "Fractal up"
#property indicator_label2 "Fractal Down"

// indicator buffers
double UpBuffer[];
double DownBuffer[];

input int FractalOrder = 3;
const int ArrowShift = 10;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  SetIndexBuffer(0, UpBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, DownBuffer, INDICATOR_DATA);

// up and down arrow character codes
  PlotIndexSetInteger(0, PLOT_ARROW, 218);
  PlotIndexSetInteger(1, PLOT_ARROW, 217);

// padding for arrow
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -ArrowShift);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, +ArrowShift);

// setting an empty value (can be ommited since EMPTY_VALUE is the default)
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//---
  return FractalOrder > 0 ? INIT_SUCCEEDED : INIT_PARAMETERS_INCORRECT;
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
  if(prev_calculated == 0)
   {
    // at the start, fill the arrays entirerly
    ArrayInitialize(UpBuffer, EMPTY_VALUE);
    ArrayInitialize(DownBuffer, EMPTY_VALUE);
   }
  else
   {
    // on new bars we also clean the elements
    for(int i = prev_calculated; i < rates_total; ++i)
     {
      UpBuffer[i] = EMPTY_VALUE;
      DownBuffer[i] = EMPTY_VALUE;
     }
   }

// view all or new bars that have bars in the FractalOrder environment
  for(int i = fmax(prev_calculated - FractalOrder - 1, FractalOrder); i < rates_total - FractalOrder; ++i)
   {
    // check if upper price is higher than neighboring bars
    UpBuffer[i] = high[i];
    for(int j = 1; j <= FractalOrder; ++j)
     {
      if(high[i] <= high[i + j] || high[i] <= high[i - j])
       {
        UpBuffer[i] = EMPTY_VALUE;
        break;
       }
     }

    // check if the lower price is lower than neighbouring bars
    DownBuffer[i] = low[i];
    for(int j = 1; j <= FractalOrder; ++j)
     {
      if(low[i] >= low[i + j] || low[i] >= low[i - j])
       {
        DownBuffer[i] = EMPTY_VALUE;
        break;
       }
     }
   }

//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
