//+------------------------------------------------------------------+
//|                                           UseEnvelopesParams.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
// drawing settings
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_label1 "Upper"
#property indicator_style1 STYLE_DOT

#property indicator_type2 DRAW_LINE
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_label2 "Lower"
#property indicator_style2 STYLE_DOT

#include <sly/RTTI.mqh>

input int WorkPeriod = 14;
input int Shift = 0;
input ENUM_MA_METHOD Method = MODE_EMA;
input ENUM_APPLIED_PRICE Price = PRICE_TYPICAL;
input double Deviation = 0.1;  // deviation %

double UpBuffer[];
double DownBuffer[];

int Handle; // handle of the surbodinate indicator
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  SetIndexBuffer(0, UpBuffer);
  SetIndexBuffer(1, DownBuffer);

  MqlParam params[5] = {};
  params[0].type = TYPE_INT;
  params[0].integer_value = WorkPeriod;
  params[1].type = TYPE_INT;
  params[1].integer_value = Shift;
  params[2].type = TYPE_INT;
  params[2].integer_value = Method;
  params[3].type = TYPE_INT;
  params[3].integer_value = Price;
  params[4].type = TYPE_DOUBLE;
  params[4].double_value = Deviation; 

  /*MqlParam params[];
  MqlParamBuilder builder;
  builder << WorkPeriod << Shift << Method << Price << Deviation >> params;
  ArrayPrint(params);*/

  Handle = IndicatorCreate(_Symbol, _Period, IND_ENVELOPES, ArraySize(params), params);
  Print(Handle);
  return Handle == INVALID_HANDLE ? INIT_FAILED : INIT_SUCCEEDED;
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
 {
  if(BarsCalculated(Handle) != rates_total)
    return prev_calculated;

  const int U = CopyBuffer(Handle, 0, 0, rates_total - prev_calculated + 1, UpBuffer);
  const int D = CopyBuffer(Handle, 1, 0, rates_total - prev_calculated + 1, DownBuffer);

//--- return value of prev_calculated for next call
  return U > -1 && D > -1 ? rates_total : 0;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MqlParamBuilder
 {
protected:
  MqlParam           array[];
  int                n;

  void               assign(const float v)
   {
    array[n].double_value = v;
   }

  void               assign(const double v)
   {
    array[n].double_value = v;
   }

  void               assign(const string v)
   {
    array[n].string_value = v;
   }

  // here we process int, enum, color, datetime, etc. compatible with long
  template<typename T>
  void               assign(const T v)
   {
    array[n].integer_value = v;
   }

public:
  template<typename T>
  MqlParamBuilder *operator<<(T v)
   {
    // expand the array
    n = ArraySize(array);
    ArrayResize(array, n + 1);
    ZeroMemory(array[n]);

    // define value type
    array[n].type = rtti(v);
    if(array[n].type == 0)
      array[n].type = TYPE_INT; // imply enum

    return &this;
   }

  void               operator>>(MqlParam &params[])
   {
    ArraySwap(array, params);
   }
 }
//+------------------------------------------------------------------+
