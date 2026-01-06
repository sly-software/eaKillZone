//+------------------------------------------------------------------+
//|                                               EnvPermissions.mqh |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"
#property version   "1.00"
class Permissions
 {
public:
  static bool        isTradeEnabled(const string symbol = NULL, const datetime session = 0)
   {
    // TODO: will be supplemented by applied checks of the symbol and sessions
    return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) 
    && MQLInfoInteger(MQL_TRADE_ALLOWED)
    //&& isTradeOnSymbolEnabled(symbol == NULL ? _Symbol: symbol, now)
    ;
   }

  static bool        isDllEnabledByDefault()
   {
    return (bool)TerminalInfoInteger(TERMINAL_DLLS_ALLOWED);
   }

  static bool        isDllEnabled()
   {
    return (bool)MQLInfoInteger(MQL_DLLS_ALLOWED);
   }

  static bool        isEmailEnabled()
   {
    return (bool)TerminalInfoInteger(TERMINAL_EMAIL_ENABLED);
   }

  static bool        isFtpEnabled()
   {
    return (bool)TerminalInfoInteger(TERMINAL_FTP_ENABLED);
   }

  static bool        isPushEnabled()
   {
    return (bool)TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);
   }

  static bool        isSignalsEnabled()
   {
    return (bool)MQLInfoInteger(MQL_SIGNALS_ALLOWED);
   }
 };
//+------------------------------------------------------------------+
