//+------------------------------------------------------------------+
//|                                                killZoneClass.mqh |
//|                                     Copyright 2026, SlySoftwares |
//|                                 https://github.com/sly-softwarem |
//+------------------------------------------------------------------+
#include <sly/Utils.mqh>
#include <sly/GetOpenPricesAndtime.mqh>

class KillZones {
  private:
    struct HighLowPricePoints {
        double highPoint;
        double lowPoint;
    };

  public:
    /* Constructor */

    /* Destructor */
    ~KillZones() {}

    /* Get Open prices of daily, weekly, monthly */
    static void GetOPOT(double & arrDOPs[], datetime & arrDOTs[],
                        double & arrWOPs[], datetime & arrWOTs[],
                        int lookBackDays, int lookBackWeeks) {

        getOP(arrDOPs, arrDOTs, lookBackDays, PERIOD_D1);     // get OP for daily draw
        getOP(arrWOPs, arrWOTs, lookBackWeeks, PERIOD_W1);    // get OP for weekly draw
    }

    /* Kill zones main function */
    static void KillZonesEngine(int daysToDraw, double & arrDOPs[], datetime & arrDOTs[], double & arrWOPs[], datetime & arrWOTs[]) {
        /* Will run on normal days and weekend */
        if(daysToDraw >= 1) {
            /* It make sense to Draw Kill Zones only on H1 and below periods */
            if(_Period <= PERIOD_H1) {
                DOP(arrDOTs, arrDOPs);

                for(int i = 0; i < daysToDraw ; i++) {
                    drawAsiaLondNewYrkKZs(arrDOTs[i],  C'25,139,250', clrOrange, clrMagenta);
                }
            }

            // If your on H4 chart draw WOP
            if(_Period <= PERIOD_H4) {
                WOP(arrWOTs, arrWOPs);
            }
        }
    }

    /* Draw Killzones for current day and previous days */
    static void drawAsiaLondNewYrkKZs(datetime date, color akzColor, color lkzColor, color nkzColor) {
        datetime akzStart = timeReformartKZ(date, "ASs");
        datetime akzEnd = timeReformartKZ(date, "ASe");
        datetime lkzStart = timeReformartKZ(date, "LNDs");
        datetime lkzEnd = timeReformartKZ(date, "LNDe");
        datetime nkzStart = timeReformartKZ(date, "NYs");
        datetime nkzEnd = timeReformartKZ(date, "NYe");
        datetime today = timeReformartKZ(TimeCurrent(), "today");
        color prevKZscolor = C'49,49,49';

        if(date == today) {
            if(TimeCurrent() >= akzStart) { // Asia Session has started
                kzRectangle(objLabelsPrefix + "Asia-Kill-Zone: " + (string)akzStart, akzColor, akzStart, akzEnd, "New KZ implementation");
            }

            if(TimeCurrent() >= lkzStart) { // London Session has started
                kzRectangle(objLabelsPrefix + "London-Kill-Zone" + (string)lkzStart, lkzColor, lkzStart, lkzEnd, "New KZ implementation");
            }

            if(TimeCurrent() >= nkzStart) { // New York Session has started
                kzRectangle(objLabelsPrefix + "NewYork-Kill-Zone" + (string)nkzStart, nkzColor, nkzStart, nkzEnd, "New KZ implementation");
            }
        } else {
            kzRectangle(objLabelsPrefix + "Asia-Kill-Zone: " + (string)akzStart, prevKZscolor, akzStart, akzEnd, "New KZ implementation");
            kzRectangle(objLabelsPrefix + "London-Kill-Zone" + (string)lkzStart, prevKZscolor, lkzStart, lkzEnd, "New KZ implementation");
            kzRectangle(objLabelsPrefix + "NewYork-Kill-Zone" + (string)nkzStart, prevKZscolor, nkzStart, nkzEnd, "New KZ implementation");
        }
    }

    /* Draw daily opening prices up to the number of lookback periods */
    static void DOP(datetime &arrDot[], double &arrDop[]) {
        for(int i = 0; i < ArraySize(arrDot) && ArraySize(arrDot) == ArraySize(arrDop); i++) {
            string dopLineName = objLabelsPrefix + "DOP:: " + TimeToString(arrDot[i]);
            datetime lnSt = DayStart(arrDot[i]);
            datetime lnEnd = DayEnd(arrDot[i] + 3600);
            double prStart = arrDop[i];
            double prEnd = arrDop[i];

            // TODO: call Draw-rectangle function here
            drawLine(lnSt, lnEnd, prStart, prEnd, dopLineName);
        }
    }

    /* Draw weekly opening price */
    static void WOP(datetime &dtStart[], double &prOpen[]) {
        for(int i = 0; i < ArraySize(dtStart) && ArraySize(dtStart) == ArraySize(prOpen); i++) {
            string wopLineName = objLabelsPrefix + "WOP:: " + TimeToString(dtStart[i]);
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

    /* Draw line given coordiantes*/
    static void drawLine(datetime lnSt, datetime lnEnd, double prOpen, double prClose, string dopLineName) {
        ObjectCreate(
            0,
            dopLineName,
            OBJ_TREND,
            0,
            lnSt,
            prOpen,
            lnEnd,
            prClose
        );

        ObjectSetInteger(ChartID(), dopLineName, OBJPROP_COLOR, C'49,49,49');
        ObjectSetInteger(ChartID(), dopLineName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(ChartID(), dopLineName, OBJPROP_WIDTH, 1);
        ObjectSetString(ChartID(), dopLineName, OBJPROP_TOOLTIP, dopLineName);
    }

    /* WILL DRAW RECTANGLE GIVEN COORDINATES AND LABELS */
    static void kzRectangle(string zone, color zoneColor, datetime timeStart, datetime timeEnd, string zoneLabelDescription) {
        HighLowPricePoints pricePoints = getHighLowPricesOfKZ(timeStart, timeEnd);

        ObjectCreate(
            ChartID(),
            zone,
            OBJ_RECTANGLE,
            0,
            timeStart,
            pricePoints.highPoint,
            timeEnd,
            pricePoints.lowPoint
        );

        ObjectSetInteger(ChartID(), zone, OBJPROP_COLOR, zoneColor);
        ObjectSetInteger(ChartID(), zone, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(ChartID(), zone, OBJPROP_BACK, true);
        ObjectSetInteger(ChartID(), zone, OBJPROP_WIDTH, 1);
        ObjectSetString(ChartID(), zone, OBJPROP_TOOLTIP, zone);
    }

    /* A FUNCTION TO GET RATES, HIGH, LOW given a time range */
    static HighLowPricePoints getHighLowPricesOfKZ(datetime tmStart, datetime tmEnd) {
        int HighestCandle, lowestCandle /*timeShift*/;
        double High[], Low[];
        MqlRates PriceInformation[];
        HighLowPricePoints pps;

        pps.highPoint = 0.0;
        pps.lowPoint = 0.0;

        ArraySetAsSeries(High, true);
        ArraySetAsSeries(Low, true);
        ArraySetAsSeries(PriceInformation, true);

        int highCopied = CopyHigh(_Symbol, _Period, tmStart, tmEnd, High);

        int highLow = CopyLow(_Symbol, _Period, tmStart, tmEnd, Low);

        int data =  CopyRates(_Symbol, _Period, tmStart, tmEnd, PriceInformation);

        if(data <= 0) {
            pps.highPoint = 0.0;
            pps.lowPoint = 0.0;

            return pps;
        }

        HighestCandle = ArrayMaximum(High, 0, WHOLE_ARRAY);
        lowestCandle = ArrayMinimum(Low, 0, WHOLE_ARRAY);

        pps.highPoint = PriceInformation[HighestCandle].high;
        pps.lowPoint = PriceInformation[lowestCandle].low;

        return pps;
    }

    /* WILL REFORMAT TIME ACCORDINGLY */
    static datetime timeReformartKZ(datetime date, string session) {
        MqlDateTime dt;

        TimeToStruct(date, dt);

        if(session == "today") {
            dt.hour = 0;
            dt.min = 0;
            dt.sec = 0;
        }

        if(session == "ASs") {
            dt.hour = 1;
            dt.min = 0;
            dt.sec = 0;
        }

        if(session == "LNDs") {
            dt.hour = 10;
            dt.min = 0;
            dt.sec = 0;
        }

        if(session == "NYs") {
            dt.hour = 15;
            dt.min = 0;
            dt.sec = 0;
        }

        if(session == "ASe") {
            dt.hour = 5;
            dt.min = 0;
            dt.sec = 0;
        }

        if(session == "LNDe") {
            dt.hour = 15;
            dt.min = 0;
            dt.sec = 0;
        }

        if(session == "NYe") {
            dt.hour = 23;
            dt.min = 0;
            dt.sec = 0;
        }

        return StructToTime(dt);
    };
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
