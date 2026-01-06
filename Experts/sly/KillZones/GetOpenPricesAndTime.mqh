//+------------------------------------------------------------------+
//|  Get Open price of last 'look-back' weeks                        |
//+------------------------------------------------------------------+
bool getOP(double &open_prices[], datetime &firstCandSticktime[],  int lbPeriod, ENUM_TIMEFRAMES period) {
// Store up to lbPeriod weeks
    ArrayResize(open_prices, lbPeriod);
    ArraySetAsSeries(open_prices, true);
    ArrayResize(firstCandSticktime, lbPeriod);
    ArraySetAsSeries(firstCandSticktime, true);

    datetime current_time = TimeCurrent();
    int copied = 0;

// Variables to store open time
// and open price of first candlestick
    datetime opTime[];
    double opPrice[];

// Copy the last 'lbPeriod' bars
    int bars = CopyTime(_Symbol, period, 0, lbPeriod + 1, opTime);

    if(bars <= 0)
        return false;       // Exit immediately if no data to copy

    int copied_bars = CopyOpen(_Symbol, period, 0, lbPeriod + 1, opPrice);

    if(copied_bars <= 0)
        return false;       // Exit immediately if no data to copy

    ArraySetAsSeries(opTime, true);
    ArraySetAsSeries(opPrice, true);


// Fill the last   lbPeriod periods
    for(int i = 0; i < bars && copied < lbPeriod; i++) {
        open_prices[copied] = opPrice[i];
        firstCandSticktime[copied] = opTime[i];
        copied++;
    }

// If we have fewer than lbPeriod periods
    while(copied < lbPeriod) {
        open_prices[copied] = 0.0;
        copied++;
    }
    return true;
}