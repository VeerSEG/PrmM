//
// (c) SEG-Automotive Germany GmbH        Tue Jun 23 23:29:11 2026
// All rights reserved,
// also regarding any disposal, exploitation, reproduction, editing, distribution,
// as well as in the event of applications for industrial property rights.
// File: PrmM_private.h
//
// Code generated for Simulink model 'PrmM'.
//
// Model version                  : 1.22
// Simulink Coder version         : 9.0 (R2018b) 24-May-2018
// C/C++ source code generated on : Tue Jun 23 23:29:11 2026
//
// Target selection: autosar.tlc
// Embedded hardware selection: Infineon->TriCore
// Code generation objective: MISRA C:2012 guidelines
// Validation result: Not run
//
#ifndef RTW_HEADER_PrmM_private_h_
#define RTW_HEADER_PrmM_private_h_
#include "rtwtypes.h"
#include "PrmM.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

extern void CS_PrmM_IfActionSubsystem1(float32 CS_MaxExt_In_u, float32
  CS_MinExt_In_u, float32 CS_MaxInt_In_u, float32 CS_MinInt_In_u, float32
  *CS_Max_Out_y, float32 *CS_Min_Out_y);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

extern void CS_PrmM_IfActionSubsystem(float32 CS_Max_In_u, float32 CS_Min_In_u,
  float32 *CS_Max_Out_y, float32 *CS_Min_Out_y);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

extern void CS_PrmM_IfActionSubsystem_aj01(float32 CS_In1_u, float32 *CS_Out1_y);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

extern void CS_PrmM_TorqueMode(float32 CS_TqLimMax_u, float32 CS_TqLimMin_u,
  float32 *CS_mTqLimMax_y, float32 *CS_mTqLimMin_y);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"
#endif                                 // RTW_HEADER_PrmM_private_h_

//
// File trailer for generated code.
//
// [EOF]
//
