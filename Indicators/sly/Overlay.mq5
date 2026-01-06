//+------------------------------------------------------------------+
//|                                                      Overlay.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

// Input parameters
string SecondarySymbol = "USINDX.Z25";
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;

// Indicator buffer
double OverlayBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
  SetIndexBuffer(0, OverlayBuffer, INDICATOR_DATA);
  PlotIndexSetString(0, PLOT_LABEL, SecondarySymbol + " Overlay");

// Validate Symbol
  if(!IsSymbolValid(SecondarySymbol)) {
    Print("Initialization failed: Invalid symbol: ", SecondarySymbol);
    return(INIT_FAILED);
  }

//---
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[]) {
//---
  int start = prev_calculated > 0 ? prev_calculated - 1 : 0;
  
  //Print(rates_total);
  
  for(int i = start; i < rates_total; i++) {

    double data = iClose(SecondarySymbol, 0, i);
    // Print(iClose(SecondarySymbol, 0, 0));
    Print(data);

    if(data == 0) {
      Print(" Erro: ", GetLastError());
    }

    if(data == 0) {
      OverlayBuffer[i] = EMPTY_VALUE;
      continue;
    }

    OverlayBuffer[i] = data;

    //Print(data);

  }
//--- return value of prev_calculated for next call
  return(rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSymbolValid(string symbl) {
  bool custom = false;
  if(!SymbolExist(symbl, custom)) {
    Print("Error: Symbol ", symbl, " Not available!");
    return false;
  }

// Attempt to select the symbol in Market Watch
  if (!SymbolSelect(symbl, true)) {
    Print("Error 4401: Symbol ", symbl, " not selected in Market Watch! Error code: ", GetLastError());
    return false;
  }

  double bid = SymbolInfoDouble(symbl, SYMBOL_BID);
  if(bid == 0.0) {
    Print("Error: Symbol ", symbl, " has no valid price data");
    return false;
  }

  return true;
}
//+------------------------------------------------------------------+
