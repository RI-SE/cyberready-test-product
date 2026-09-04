# Software Safety Class

This file records an IEC 62304-inspired safety-class rationale for glucose-log as a CyberReady reference example.
It is not a notified-body classification, not a medical-device registration, and not a claim that glucose-log conforms to IEC 62304.

glucose-log does not diagnose, treat, calculate insulin, or control a device. It stores numbers a user types.

## Classification Rationale

Documented class for this reference example: Class A.

IEC 62304 Class A is the class used when no injury or damage to health is possible. glucose-log only persists a user-entered number and shows it back. An incorrect stored value does not itself dose a patient, because the product has no dosing, alarming, or treatment functions.

If this software were later changed to calculate insulin or to drive a pump, this rationale would be invalid and the class would have to be revisited. That behaviour is an explicit non-goal of glucose-log.
