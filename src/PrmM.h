//
// File: PrmM.h
//
// Code generated for Simulink model 'PrmM'.
//
// Model version                  : 15.14
// Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
// C/C++ source code generated on : Tue Nov 10 23:20:14 2026
//
// Target selection: autosar.tlc
// Embedded hardware selection: Infineon->TriCore
// Code generation objective: MISRA C:2012 guidelines
// Validation result: Not run
//
#ifndef PrmM_h_
#define PrmM_h_
#ifndef PrmM_COMMON_INCLUDES_
#define PrmM_COMMON_INCLUDES_
#include "Platform_Types.h"
#include "Rte_PrmM.h"
#endif                                 // PrmM_COMMON_INCLUDES_

#include "Rte_Type.h"
#include <string.h>

// Block signals (default storage)
typedef struct PrmM_tag_B {
  float32 Merge;                       // '<S31>/Merge'
  float32 Merge1;                      // '<S31>/Merge1'
  float32 Merge_kxzf;                  // '<S35>/Merge'
  float32 Merge1_dwug;                 // '<S35>/Merge1'
  float32 Merge_ade1;                  // '<S64>/Merge'
  float32 Merge1_nlaf;                 // '<S64>/Merge1'
  float32 Switch1_b3rg;                // '<S41>/Switch1'
  float32 Merge_nrgp;                  // '<S5>/Merge'
  float32 Merge1_b0bp;                 // '<S5>/Merge1'
} PrmM_B;

// Block signals (default storage)
#define PrmM_START_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

extern PrmM_B PrmM_B_n4wy;

#define PrmM_STOP_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

// Exported data declaration
#define PrmM_START_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"

// Declaration for custom storage class: CalParam
extern const volatile float32 CS_PrmM_mMaxTqGrdtInt_XDF32;// Referenced by: '<S48>/calParam' 

// Maximum internal torque request gradient. Nm per second.

extern const volatile float32 CS_PrmM_nHSpdBd_XDF32;// Referenced by: '<S51>/calParam' 

// Above this speed lower bound of  torque request is set to minimum electromagnetical limit.  
extern const volatile float32 CS_PrmM_nLwrSpdBd_XDF32;// Referenced by: '<S52>/calParam' 

// Below this speed drag torque is set as torque request
extern const volatile float32 CS_PrmM_uDcMaxBattLess_XDF32;// Referenced by: '<S12>/calParam' 

// Internal value to restrict maximum voltage limit for Batteryless mode.
extern const volatile float32 CS_PrmM_uDcMaxOtherM_XDF32;// Referenced by: '<S14>/calParam' 

// Internal value to restrict maximum voltage limit for speed, torque or communicationless mode. 
extern const volatile float32 CS_PrmM_uDcMaxVoltMode_XDF32;// Referenced by: '<S16>/calParam' 

// Internal value to restrict maximum voltage limit for voltage mode.
extern const volatile float32 CS_PrmM_uDcMinBattLess_XDF32;// Referenced by: '<S13>/calParam' 

// Internal value to restrict minimum voltage limit fo Batteryless mode.
extern const volatile float32 CS_PrmM_uDcMinOtherM_XDF32;// Referenced by: '<S15>/calParam' 

// Internal value to restrict minimum voltage limit for speed, torque or communicationless mode. 
extern const volatile float32 CS_PrmM_uDcMinVoltMode_XDF32;// Referenced by: '<S17>/calParam' 

// Internal value to restrict minimum voltage limit for voltage mode.
#define PrmM_STOP_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"

// Declaration for custom storage class: CalParam
extern const volatile boolean CS_PrmM_fTqGrdSelect_XDB;// Referenced by: '<S47>/calParam' 

// Gradient method selector. True: Internal Value  False: Value from CAN
#define PrmM_STOP_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

// Declaration for custom storage class: CalSignal
extern float32 CS_PrmM_iReqMaxBattI_xdf32;// '<S19>/buffer'

// Maximun battery current limit
extern float32 CS_PrmM_iReqMinBattI_xdf32;// '<S20>/buffer'

// Minimun battery current limit
extern float32 CS_PrmM_mReqTq_xdf32;   // '<S21>/buffer'

// requested torque
extern float32 CS_PrmM_mTqLimMax_xdf32;// '<S42>/buffer'

// Maximum torque limit
extern float32 CS_PrmM_mTqLimMin_xdf32;// '<S43>/buffer'

// Minimun torque limit
extern float32 CS_PrmM_mTqminmerge_xdf32;// '<S50>/buffer'
extern float32 CS_PrmM_nReqSpd_xdf32;  // '<S22>/buffer'

// requested mechanical speed
extern float32 CS_PrmM_uReqMaxBattU_xdf32;// '<S23>/buffer'

// Maximum battery voltage limit
extern float32 CS_PrmM_uReqMinBattU_xdf32;// '<S24>/buffer'

// Minimun battery voltage limit
extern float32 CS_PrmM_uReqU_xdf32;    // '<S25>/buffer'

// requested DC voltage
extern float32 CS_PrmM_yMaxTqGrdt_xdf32;// '<S44>/buffer'

// Maximmun gradient limit
#define PrmM_STOP_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

//-
//  The generated code includes comments that allow you to trace directly
//  back to the appropriate location in the model.  The basic format
//  is <system>/block_name, where system is the system number (uniquely
//  assigned by Simulink) and block_name is the name of the block.
//
//  Use the MATLAB hilite_system command to trace the generated code back
//  to the model.  For example,
//
//  hilite_system('<S3>')    - opens system 3
//  hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
//
//  Here is the system hierarchy for this model
//
//  '<Root>' : 'PrmM'
//  '<S1>'   : 'PrmM/PrmM_Init'
//  '<S2>'   : 'PrmM/PrmM_Proc_100ms_sys'
//  '<S3>'   : 'PrmM/PrmM_Proc_1ms_sys'
//  '<S4>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms'
//  '<S5>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits'
//  '<S6>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/SendingParameters'
//  '<S7>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/BatterylessOperation'
//  '<S8>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/CompareToConstant'
//  '<S9>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/CompareToConstant1'
//  '<S10>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/Other'
//  '<S11>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/VoltageMode'
//  '<S12>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/BatterylessOperation/CS_PrmM_uDcMaxBattLess_XDF32'
//  '<S13>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/BatterylessOperation/CS_PrmM_uDcMinBattLess_XDF32'
//  '<S14>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/Other/CS_PrmM_uDcMaxOtherM_XDF32'
//  '<S15>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/Other/CS_PrmM_uDcMinOtherM_XDF32'
//  '<S16>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/VoltageMode/CS_PrmM_uDcMaxVoltMode_XDF32'
//  '<S17>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/VoltageMode/CS_PrmM_uDcMinVoltMode_XDF32'
//  '<S18>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms'
//  '<S19>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_iReqMaxBattI_xdf32'
//  '<S20>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_iReqMinBattI_xdf32'
//  '<S21>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_mReqTq_xdf32'
//  '<S22>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_nReqSpd_xdf32'
//  '<S23>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_uReqMaxBattU_xdf32'
//  '<S24>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_uReqMinBattU_xdf32'
//  '<S25>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_uReqU_xdf32'
//  '<S26>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim'
//  '<S27>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes'
//  '<S28>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim'
//  '<S29>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits'
//  '<S30>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits'
//  '<S31>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus'
//  '<S32>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus/IfActionSubsystem'
//  '<S33>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus/IfActionSubsystem1'
//  '<S34>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus/InternLimPlaus'
//  '<S35>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus'
//  '<S36>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus/IfActionSubsystem'
//  '<S37>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus/IfActionSubsystem1'
//  '<S38>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus/InternLimPlaus'
//  '<S39>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant3'
//  '<S40>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant4'
//  '<S41>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/VoltDesDetermin'
//  '<S42>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CS_PrmM_mTqLimMax_xdf32'
//  '<S43>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CS_PrmM_mTqLimMin_xdf32'
//  '<S44>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CS_PrmM_yMaxTqGrdt_xdf32'
//  '<S45>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit'
//  '<S46>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation'
//  '<S47>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit/CS_PrmM_fTqGrdSelect_XDB'
//  '<S48>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit/CS_PrmM_mMaxTqGrdtInt_XDF32'
//  '<S49>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit/CompareToConstant'
//  '<S50>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_mTqminmerge_xdf32'
//  '<S51>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_nHSpdBd_XDF32'
//  '<S52>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_nLwrSpdBd_XDF32'
//  '<S53>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant'
//  '<S54>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant3'
//  '<S55>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant4'
//  '<S56>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant6'
//  '<S57>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant7'
//  '<S58>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem'
//  '<S59>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem1'
//  '<S60>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem2'
//  '<S61>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem3'
//  '<S62>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem4'
//  '<S63>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem5'
//  '<S64>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus'
//  '<S65>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/MATLABFunction'
//  '<S66>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/IfActionSubsystem'
//  '<S67>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/IfActionSubsystem1'
//  '<S68>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/InternLimPlaus'
//  '<S69>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/Subsystem'


//-
//  Requirements for '<Root>': PrmM



#endif                                 // PrmM_h_

//
// File trailer for generated code.
//
// [EOF]
//
