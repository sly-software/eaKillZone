//+------------------------------------------------------------------+
//|                                                   CIndicator.mqh |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"

class CIndicator {
 protected:
  int handle;
  double main[];

 public:
  CIndicator() {
    ArraySetAsSeries(this.main, true);
  }

  double Main(int count, int pShift = 0) {
    CopyBuffer(this.handle, 0, 0, count, this.main);
    double value = NormalizeDouble(this.main[pShift], _Digits);
    return value;
  }

  void Release() {
    IndicatorRelease(this.handle);
  }

  virtual int Init() {
    return this.handle;
  }
};
//+------------------------------------------------------------------+


// derived class CiMA
class CiMA: public CIndicator {
 public:
  int Init(string pSymbol,
           ENUM_TIMEFRAMES pTimeframe,
           int pMAPeriod,
           int pMAShift,
           ENUM_MA_METHOD pMAMethod,
           ENUM_APPLIED_PRICE pMAPrice) {

    this.handle = iMA(pSymbol, pTimeframe, pMAPeriod, pMAShift, pMAMethod, pMAPrice);

    return this.handle;
  }
;
//+------------------------------------------------------------------+
