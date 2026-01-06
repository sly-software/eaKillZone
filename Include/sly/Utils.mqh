//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"

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
//|                                                                  |
//+------------------------------------------------------------------+
void refomatTime(datetime &tmArr[], int dB) {
    MqlDateTime dt;
    datetime tempDateArr[];
    int j = 0;
    int count = 0;

    ArrayResize(tempDateArr, dB);
    ArrayResize(tmArr, dB);

    while(count < dB) {
        datetime temp = TimeCurrent() - j * 24 * 60 * 60;
        if(!isWeekEnd(temp)) {
            tempDateArr[count] = temp;
            count += 1;
        }
        j++;
    }
    for(int i = 0; i < dB; i++) {
        TimeToStruct(tempDateArr[i], dt);
        dt.hour = 0;
        dt.min = 0;
        dt.sec = 0;
        tmArr[i] = StructToTime(dt);
    }
};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isWeekEnd(datetime day) {
    MqlDateTime dt;
    TimeToStruct(day, dt);
    if(dt.day_of_week == 0 || dt.day_of_week == 6) {
        return true;
    }
    return false;
}

