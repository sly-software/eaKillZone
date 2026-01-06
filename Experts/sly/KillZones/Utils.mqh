//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"

class KillZones {
  private:
    int AsianStart, AsianEnd, LondonStart, LondonEnd, NYStart, NYEnd;
    color clrLiveSessionStart, clrLivesessionEnd, rectCol;
    datetime lastRunDate, today;
    long chartId;
    string lndnSession, nySession, AsiaSession, lineNameDOP;
    bool aFlag, lFlag, nyFlag;


    struct HighLowPricePoints {
        double highPoint;
        double lowPoint;
    };

  public:
    static int counter;

    // Constructor
    KillZones(
        int AsS, int AsE, int LndS, int LndE, int NYS, int NYE, color colLiveS,
        color colEndS, datetime date
    ) {
        this.AsianStart = AsS;
        this.AsianEnd = AsE;
        this.LondonStart = LndS;
        this.LondonEnd = LndE;
        this.NYStart = NYS;
        this.NYEnd = NYE;
        this.today = date;
        this.clrLiveSessionStart = colLiveS;
        this.clrLivesessionEnd = colEndS;
        this.chartId = ChartID();
        this.rectCol = C'49,49,49';
        this.aFlag = true;
        this.lFlag = true;
        this.nyFlag = true;
        this.lastRunDate = 0;
        this.AsiaSession = "KZO-Asian Session: " + TimeToString(this.today, TIME_DATE);
        this.lndnSession = "KZO-London Session: " + TimeToString(this.today, TIME_DATE);
        this.nySession = "KZO-New York Session: " + TimeToString(this.today, TIME_DATE);
        this.lineNameDOP = "KZO-Daily Open Price" + TimeToString(this.today, TIME_DATE);
    }

    // Destructor
    ~KillZones() {}

    string getAssRangeLbl() {
        return this.AsiaSession;
    }

    string getLndRangeLbl() {
        return this.lndnSession;
    }

    string getNykRangeLbl() {
        return this.nySession;
    }

    string getIcSsLbl(string sessionLbel, int status) {
        if(status == 0) {
            return sessionLbel + "::IS_Start";
        } else {
            return sessionLbel + "::IS_End";
        }
    }

    string getActvSsLbl(string sessionLbel, int status) {
        if(status == 0) {
            return sessionLbel + "::Cr_Start";
        } else {
            return sessionLbel + "::Cr_End";
        }
    }

    string getDOPNlineName() {
        return this.lineNameDOP;
    }

    // Draw weekly opening price
    static void WOP(datetime &dtStart[], double &prOpen[]) {

        // Draw weekly opening prices up to the number of lookback periods
        for(int i = 0; i < ArraySize(dtStart) && ArraySize(dtStart) == ArraySize(prOpen); i++) {
            string wopLineName = "KZO-WOP:: " + TimeToString(dtStart[i]);
            datetime lnSt = DayStart(dtStart[i]);
            datetime lnEnd = DayEnd(dtStart[i] + 5 * 86400);

            ObjectCreate(
                0,
                wopLineName,
                OBJ_TREND,
                0,
                lnSt,
                prOpen[i],
                lnEnd,
                prOpen[i]
            );

            ObjectSetInteger(ChartID(), wopLineName, OBJPROP_COLOR, clrSnow);
            ObjectSetInteger(ChartID(), wopLineName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(ChartID(), wopLineName, OBJPROP_WIDTH, 1);
            ObjectSetString(ChartID(), wopLineName, OBJPROP_TOOLTIP, wopLineName);
        }
    }


    void kzDrawEngine() {

        if(_Period < PERIOD_H4) {
            this.lastRunDate = this.today;
            MqlDateTime dt, dtP;

            TimeToStruct(TimeCurrent(), dt);
            TimeToStruct(this.today, dtP);

            //Print(dtP.day == dt.day);


            datetime openT = iTime(_Symbol, PERIOD_D1, 0);
            int idxOpenBar = iBarShift(_Symbol, _Period, openT, false);
            datetime firstCandleTime = iTime(_Symbol, _Period, idxOpenBar);


            if(dtP.day == dt.day ) { // Draw today
            
                // Draw daily open price on H1 and less TF --- USEFULL FOR TRADING THE POWER OF THREE
                double dOpenP = iOpen(_Symbol, PERIOD_D1, 0);

                if(_Period <= PERIOD_H1) {
                    this.drawLine(dtP, dOpenP);
                }

                // New York Session
                if(dt.hour < this.NYStart) { // Sessio hasn't started

                    this.ActiveSession(getIcSsLbl(getNykRangeLbl(), 0), this.today + this.NYStart * 3600, this.clrLiveSessionStart);
                    this.ActiveSession(getIcSsLbl(getNykRangeLbl(), 1), this.today + this.NYEnd * 3600, this.clrLiveSessionStart);

                    nyFlag = !nyFlag;

                } else if(dt.hour >= this.NYStart && dt.hour < this.NYEnd) { // Session started
                    // Cleanup
                    removeKZObjects(getIcSsLbl(getNykRangeLbl(), 0));
                    removeKZObjects(getIcSsLbl(getNykRangeLbl(), 1));

                    this.ActiveSession(getActvSsLbl(getNykRangeLbl(), 0), this.today + this.NYStart * 3600, clrIndigo);
                    this.ActiveSession(getActvSsLbl(getNykRangeLbl(), 1), this.today + this.NYEnd * 3600, this.clrLivesessionEnd);

                } else if(dt.hour >= this.NYEnd) { // Session has ended
                    // Cleanup
                    removeKZObjects(getActvSsLbl(getNykRangeLbl(), 0));
                    removeKZObjects(getActvSsLbl(getNykRangeLbl(), 1));

                    this.rectangle(getNykRangeLbl(),
                                   clrIndigo,
                                   this.today + this.NYStart * 3600,
                                   this.today + this.NYEnd * 3600,
                                   1,
                                   "NYlabel",
                                   "NYKZ");
                }

                // Asian Session
                if(dt.hour < this.AsianStart) { // Sessio hasn't started
                    this.ActiveSession(getIcSsLbl(getAssRangeLbl(), 0), this.today + this.AsianStart * 3600, this.clrLiveSessionStart);
                    this.ActiveSession(getIcSsLbl(getAssRangeLbl(), 1), this.today + this.AsianEnd * 3600, this.clrLiveSessionStart);
                    aFlag = !aFlag;

                } else if(dt.hour >= this.AsianStart && dt.hour < this.AsianEnd) { // Session started

                    // Cleanup
                    removeKZObjects(getIcSsLbl(getAssRangeLbl(), 0));
                    removeKZObjects(getIcSsLbl(getAssRangeLbl(), 1));

                    this.ActiveSession(getActvSsLbl(getAssRangeLbl(), 0), this.today + this.AsianStart * 3600, clrSteelBlue);
                    this.ActiveSession(getActvSsLbl(getAssRangeLbl(), 1), this.today + this.AsianEnd * 3600, this.clrLivesessionEnd);

                } else if(dt.hour >= this.AsianEnd) { // Session has ended
                    // Cleanup
                    removeKZObjects(getActvSsLbl(getAssRangeLbl(), 0));
                    removeKZObjects(getActvSsLbl(getAssRangeLbl(), 1));

                    this.rectangle(getAssRangeLbl(),
                                   clrSteelBlue, today + this.AsianStart * 3600,
                                   this.today + this.AsianEnd * 3600,
                                   1,
                                   "AsLabel",
                                   "AKZ");
                }

                // London Session
                if(dt.hour < this.LondonStart) { // Sessio hasn't started
                    this.ActiveSession(getIcSsLbl(getLndRangeLbl(), 0), this.today + this.LondonStart * 3600, this.clrLiveSessionStart);
                    this.ActiveSession(getIcSsLbl(getLndRangeLbl(), 1), this.today + this.LondonEnd * 3600, this.clrLiveSessionStart);
                    lFlag = !lFlag;

                } else if(dt.hour >= this.LondonStart && dt.hour < this.LondonEnd) { // Session started

                    // Cleanup
                    removeKZObjects(getIcSsLbl(getLndRangeLbl(), 0));
                    removeKZObjects(getIcSsLbl(getLndRangeLbl(), 1));

                    this.ActiveSession(getActvSsLbl(getLndRangeLbl(), 0), this.today + this.LondonStart * 3600, clrGoldenrod);
                    this.ActiveSession(getActvSsLbl(getLndRangeLbl(), 1), this.today + this.LondonEnd * 3600, this.clrLivesessionEnd);

                } else if(dt.hour >= this.LondonEnd) { // Session has ended
                    // Cleanup
                    removeKZObjects(getActvSsLbl(getLndRangeLbl(), 0));
                    removeKZObjects(getActvSsLbl(getLndRangeLbl(), 1));

                    this.rectangle(getLndRangeLbl(),
                                   clrGoldenrod,
                                   this.today + this.LondonStart * 3600,
                                   this.today + this.LondonEnd * 3600,
                                   1,
                                   "LndLabel",
                                   "LKZ");
                }

                // Draw Asian range -- might act as a refference point for the NYIS to take trade
                if(dt.hour >= this.LondonStart && false/*&& _Symbol == "XAUUSD@"*/) {

                    this.rectangle("KZO-AsianRange",
                                   this.clrLiveSessionStart,
                                   firstCandleTime,
                                   this.today + this.LondonStart * 3600,
                                   1,
                                   "AsianRangeLabel",
                                   "A.Rng");
                }
            } else { // Draw past days sessions
                int idxOpenBar = iBarShift(_Symbol, PERIOD_D1, this.today);
                double openP = iOpen(_Symbol, PERIOD_D1, idxOpenBar);

                // Draw DOP of previous days other than active trading days
                this.drawLine(dtP, openP);

                this.rectangle(getAssRangeLbl(),
                               rectCol, this.today + this.AsianStart * 3600,
                               this.today + this.AsianEnd * 3600,
                               2,
                               "AsLabel",
                               "AKZ");

                this.rectangle(getLndRangeLbl(),
                               rectCol,
                               this.today + this.LondonStart * 3600,
                               this.today + this.LondonEnd * 3600,
                               2,
                               "LndLabel",
                               "LKZ");

                this.rectangle(getNykRangeLbl(),
                               rectCol,
                               this.today + this.NYStart * 3600,
                               this.today + this.NYEnd * 3600,
                               2,
                               "NYlabel",
                               "NYKZ");
            }
        } // firts if statement
        ChartRedraw(0);
    }

    void ActiveSession(string baseName, datetime timeStart, color zoneColor) {
        ObjectCreate(chartId, baseName, OBJ_VLINE, 0, timeStart, 0);

        ObjectSetInteger(chartId, baseName, OBJPROP_COLOR, zoneColor);
        ObjectSetInteger(chartId, baseName, OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSetInteger(chartId, baseName, OBJPROP_WIDTH, 1);
        ObjectSetInteger(chartId, baseName, OBJPROP_BACK, true); // Send to background
    }

    void rectangle(string zone, color zoneColor, datetime timeStart, datetime timeEnd,
                   int recWidth, string zoneLabel, string zoneLabelDescription) {

        HighLowPricePoints pricePoints = this.priceRange(timeStart, timeEnd);

        // The rectangle
        ObjectCreate(
            chartId,
            zone,
            OBJ_RECTANGLE,
            0,
            timeStart,
            pricePoints.highPoint,
            timeEnd,
            pricePoints.lowPoint
        );

        ObjectSetInteger(chartId, zone, OBJPROP_COLOR, zoneColor);
        ObjectSetInteger(chartId, zone, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(chartId, zone, OBJPROP_BACK, true);
        ObjectSetInteger(chartId, zone, OBJPROP_WIDTH, recWidth);
        ObjectSetString(chartId, zone, OBJPROP_TOOLTIP, zone);
    }

    void Text(long cID,
              datetime tmStart,
              datetime tmEnd,
              string name,
              string content,
              string font,
              int fontSize,
              double angle,
              color sessionClr) {

        HighLowPricePoints pricePoints = this.priceRange(tmStart, tmEnd);
        double padding = (_Point == 0.01) ? 4 : _Point * 10;


        if(!ObjectCreate(cID, name, OBJ_TEXT, 0, tmStart, pricePoints.highPoint + padding)) {
            Print(__FUNCTION__,
                  ": failed to create \"Text\" object! Error code = ", GetLastError());
        }

        ObjectSetString(chartId, name, OBJPROP_TEXT, content);
        ObjectSetString(chartId, name, OBJPROP_FONT, font);
        ObjectSetInteger(chartId, name, OBJPROP_FONTSIZE, fontSize);
        ObjectSetDouble(chartId, name, OBJPROP_ANGLE, angle);
        ObjectSetInteger(chartId, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(chartId, name, OBJPROP_COLOR, sessionClr);
        ObjectSetInteger(chartId, name, OBJPROP_BACK, true);
    }

    void drawWOP() {
        if (_Period == PERIOD_H4) {
            double WOP = iOpen(_Symbol, PERIOD_W1, 0); // Daily open price
            Print("TRUE: " + (string)WOP);
        }
    }

    /* FUNCTION: Given coordinated draw a line */
    void drawLine(MqlDateTime & ancDt, double prcAnc) {

        datetime lnSt = StringToTime((string)ancDt.year + "." + (string)ancDt.mon + "." + (string)ancDt.day  + " 01:00:00");
        datetime lnEnd = StringToTime((string)ancDt.year + "." + (string)ancDt.mon + "." + (string)ancDt.day  + " 23:59:59");

        ObjectCreate(
            this.chartId,
            getDOPNlineName(),
            OBJ_TREND,
            0,
            lnSt,
            prcAnc,
            lnEnd,
            prcAnc
        );

        ObjectSetInteger(this.chartId, getDOPNlineName(), OBJPROP_COLOR, this.rectCol);
        ObjectSetInteger(this.chartId, getDOPNlineName(), OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(this.chartId, getDOPNlineName(), OBJPROP_WIDTH, 1);
        ObjectSetString(this.chartId, getDOPNlineName(), OBJPROP_TOOLTIP, getDOPNlineName());
    }


    /* FUNCTION: Delete previous incomming sessions objects */
    void removeKZObjects(string objName) {
        ObjectsDeleteAll(this.chartId, objName);
    }

    /* FUNCTION: Given a date check if is a weekend */
    bool isWeekEnd(datetime day) {
        MqlDateTime dt;
        TimeToStruct(day, dt);
        if(dt.day_of_week == 0 || dt.day_of_week == 6) {
            return true;
        }
        return false;
    }

    datetime StartOfDay(datetime time) {
        MqlDateTime dt;
        TimeToStruct(time, dt);

        dt.hour = 0;
        dt.min = 0;
        dt.sec = 0;

        return StructToTime(dt);
    }

    HighLowPricePoints priceRange(datetime tmStart, datetime tmEnd) {
        int HighestCandle, lowestCandle /*timeShift*/;
        double High[], Low[];
        MqlRates PriceInformation[];
        HighLowPricePoints pps;

        pps.highPoint = 0.0;
        pps.lowPoint = 0.0;

        ArraySetAsSeries(High, true);
        ArraySetAsSeries(Low, true);
        ArraySetAsSeries(PriceInformation, true);

        CopyHigh(_Symbol, _Period, tmStart, tmEnd, High);
        CopyLow(_Symbol, _Period, tmStart, tmEnd, Low);

        int data =  CopyRates(Symbol(), Period(), tmStart, tmEnd, PriceInformation);

        HighestCandle = ArrayMaximum(High, 0, WHOLE_ARRAY);
        lowestCandle = ArrayMinimum(Low, 0, WHOLE_ARRAY);

        pps.highPoint = PriceInformation[HighestCandle].high;
        pps.lowPoint = PriceInformation[lowestCandle].low;

        return pps;
    }

};

//+------------------------------------------------------------------+
//|  Return the start of the day (00:00:00) for a given datetime     |
//+------------------------------------------------------------------+
datetime DayStart(datetime any_time) {
    MqlDateTime tm;
    TimeToStruct(any_time, tm);          // split into struct
    tm.hour = 0;
    tm.min  = 0;
    tm.sec  = 0;
    return StructToTime(tm);             // 00:00:00 of that day
}

//+------------------------------------------------------------------+
//|  Return the end of the day (23:59:59) for a given datetime       |
//+------------------------------------------------------------------+
datetime DayEnd(datetime any_time) {
    MqlDateTime tm;
    TimeToStruct(any_time, tm);
    tm.hour = 23;
    tm.min  = 59;
    tm.sec  = 59;
    return StructToTime(tm);             // 23:59:59 of that day
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
class RectangleSplitter {
  private:
    string rect1Name, rect2Name, lineName;
    datetime time1, time2;
    double price1, price2, midPrice;
    color clProfit, clLoss;

  public:
    RectangleSplitter(
        string r1,
        string r2,
        string ln,
        datetime t1,
        datetime t2,
        double p1,
        double p2,
        color pf,
        color sl
    ) {
        rect1Name = r1;
        rect2Name = r2;
        lineName = ln;
        time1 = t1;
        time2 = t2;
        price1 = p1;
        price2  = p2;
        midPrice = price1 + (price2 - price1) / 2;
        clProfit = pf;
        clLoss = sl;
    }

    RectangleSplitter() {
        this.time1 = TimeCurrent() - 3600 * 24;
        this.time2 = TimeCurrent();
        this.price1 = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (_Point == 0.01 ? 300 * _Point : 100 * _Point);
        this.price2 = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (_Point == 0.01 ? 300 * _Point : 100 * _Point);
        this.rect1Name =  "UpperRect";
        this.rect2Name =  "LowerRect";
        this.lineName = "DividerLine";
        this.midPrice = this.price1 + (this.price2 - this.price1) / 2;
        this.clProfit = clrMediumBlue;
        this.clLoss = clrOrangeRed;
    }

    double getUpperRectPrice() {
        return this.price1;
    }

    double getLowerRectPrice() {
        return this.price2;
    }

    double calculateMidPrice(double prc1, double prc2) {
        return (prc1 + (prc2 - prc1) / 2);
    }

    double ensureMidInBound(double prc1, double prc2, double midPt) {
        // Ensure mid stays with bounds
        if(midPt > prc1) return prc1 - _Point;
        if(midPt < prc2) return prc2 + _Point;

        this.midPrice = midPt;

        return this.midPrice;
    }

    void drawSplitRectangle() {
        // Upper rectangle
        ObjectCreate(0, rect1Name, OBJ_RECTANGLE, 0, time1, price1, time2, midPrice);
        ObjectSetInteger(0, rect1Name, OBJPROP_COLOR, clProfit);
        ObjectSetInteger(0, rect1Name, OBJPROP_FILL, true);
        ObjectSetInteger(0, rect1Name, OBJPROP_BGCOLOR, clProfit);
        ObjectSetInteger(0, rect1Name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, rect1Name, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, rect1Name, OBJPROP_SELECTED, true);

        // Lower rectangle
        ObjectCreate(0, rect2Name, OBJ_RECTANGLE, 0, time1, midPrice, time2, price2);
        ObjectSetInteger(0, rect2Name, OBJPROP_COLOR, clLoss);
        ObjectSetInteger(0, rect2Name, OBJPROP_FILL, true);
        ObjectSetInteger(0, rect2Name, OBJPROP_BGCOLOR, clLoss);
        ObjectSetInteger(0, rect2Name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, rect2Name, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, rect2Name, OBJPROP_SELECTED, true);

        // Draggable middle line
        ObjectCreate(0, lineName, OBJ_TREND, 0, time1, midPrice, time2, midPrice);
        ObjectSetInteger(0, lineName, OBJPROP_COLOR, clLoss);
        ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, lineName, OBJPROP_SELECTED, true);
        ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);

        ChartRedraw();
    }

    void updateMidPrice(double nPrc1, double nPrc2, double nMidPrc) {
        if(nMidPrc != this.midPrice) {
            this.midPrice = this.ensureMidInBound(this.price1, this.price2, nMidPrc);
            // Adjust mid-line accordingly
            this.moveObjects(this.price1, this.time1, this.price2, this.time2, this.midPrice);
        }
    }

    void moveObjects(double nPrc1, datetime nTm1, double nPrc2, datetime nTm2, double nMidPrc) {
        // Update upper rectangle
        ObjectMove(0, rect1Name, 0, nTm1, nPrc1);
        ObjectMove(0, rect1Name, 1, nTm2, nMidPrc);

        // Update lower rectangle (midPrice to price2)
        ObjectMove(0, rect2Name, 0, nTm1, nMidPrc);
        ObjectMove(0, rect2Name, 1, nTm2, nPrc2);

        ObjectMove(0, lineName, 0, nTm1, nMidPrc);
        ObjectMove(0, lineName, 1, nTm2, nMidPrc);

        ChartRedraw();
    }

    void updateRectangle() {
        double nR1Price1 = ObjectGetDouble(0, rect1Name, OBJPROP_PRICE, 0);
        long nR1Tm1 = ObjectGetInteger(0, rect1Name, OBJPROP_TIME, 0);

        double nR2Price2 = ObjectGetDouble(0, rect2Name, OBJPROP_PRICE, 1);
        long nR2Tm2 = ObjectGetInteger(0, rect2Name, OBJPROP_TIME, 1);

        //Print(nR1Price1 < nR2Price2);

        // upper rectangle moved
        if(nR1Tm1 !=  this.time1) { // Drag from left corner
            this.moveObjects(nR1Price1, nR1Tm1, this.price2, this.time2, this.midPrice);
            this.price1 = nR1Price1;
            this.time1 = (datetime)nR1Tm1;
        }
        if(nR2Price2 !=  this.price2) { // Drag from right corner
            this.moveObjects(this.price1, this.time1, nR2Price2, nR2Tm2, this.midPrice);
            this.price2 = nR2Price2;
            this.time2 = (datetime)nR2Tm2;
        }
    }

    void removeObjects() {
        ObjectDelete(0, rect1Name);
        ObjectDelete(0, rect2Name);
        ObjectDelete(0, lineName);
        ChartRedraw();
    }
};
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
