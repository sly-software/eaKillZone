//+------------------------------------------------------------------+
//|                                                    killZones.mq5 |
//|                                     Copyright 2025, sylsoftwares |
//|                                  https://github.com/sly-software |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://github.com/sly-software"
#property version   "1.00"

#include <sly/killZoneClass.mqh>
#include <sly/Utils.mqh>

input int kzDaysback = 0;
input int wopLookbackPeriod = 0;

// Global instance
static double arrDOP[], arrWOP[], arrMOP[];
static datetime arrDOT[], arrWOT[], ArrMOT[];
string objLabelsPrefix = "KZO--";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    ObjectsDeleteAll(0, objLabelsPrefix);

    KillZones::GetOPOT(arrDOP, arrDOT, arrWOP, arrWOT, kzDaysback, wopLookbackPeriod);
    KillZones::KillZonesEngine(kzDaysback, arrDOP, arrDOT, arrWOP, arrWOT);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    KillZones::KillZonesEngine(kzDaysback, arrDOP, arrDOT, arrWOP, arrWOT);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    ObjectsDeleteAll(0, objLabelsPrefix);
    EventKillTimer();
    ChartRedraw();
}
//+------------------------------------------------------------------+
