//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"

class CTrade {
 private:
  MqlTradeRequest request;
  bool OpenPosition(string pSymbol, ENUM_ORDER_TYPE pType, double pVolume,
                    double pStop = 0, double pProfit = 0, string pComment = NULL);

 public:
  MqlTradeCheckResult result;
};
//+------------------------------------------------------------------+

// methods
bool CTrade::OpenPosition(string pSymbol, ENUM_ORDER_TYPE pType,
                          double pVolume, double pStop = 0.000000,
                          double pProfit = 0.000000, string pComment = NULL) {

// filling the request object
  request.action = TRADE_ACTION_DEAL;
  request.symbol = pSymbol;
  request.type = pType;
  request.sl = pStop;
  request.tp = pProfit;
  request.comment = pComment;

// for non-hedging accounts
  double positionLots = 0;
  long positionType = WRONG_VALUE;

  if(PositionSelect(pSymbol) == true) {
    positionLots = PositionGetDouble(POSITION_VOLUME);
    positionType = PositionGetInteger(POSITION_TYPE);
  }

  if((pType == ORDER_TYPE_BUY && positionType == POSITION_TYPE_SELL)
      || (pType == ORDER_TYPE_SELL && positionType == POSITION_TYPE_BUY)) {
    request.volume = pVolume + positionLots;
  } else {
    request.volume = pVolume;
  }
}
//+------------------------------------------------------------------+
