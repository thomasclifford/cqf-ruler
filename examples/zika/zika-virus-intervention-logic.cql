library "zika-virus-intervention-logic" version '1.0.1'

using FHIR version '3.0.0'

codesystem "Example Questionnaires": 'http://example.org/questionnaires'

valueset "Pregnancy": 'X.Y.Z'
valueset "Zika Affected Areas": '2.16.840.1.114222.4.11.7457' // Value set has been created based upon Jan 26th, 2016 travel notice from CDC Zika virus disease website	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7457
valueset "Zika Virus Signs and Symptoms": '2.16.840.1.114222.4.11.7459' // https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7459
valueset "General Arbovirus Signs and Symptoms": '2.16.840.1.114222.4.11.7460' // Signs and Symptoms of Arboviral diseases. This value set would be used for public health case notification and includes signs and symptoms of Dengue, Chikungunya and Zika.	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7460
valueset "Zika Virus Tests": '2.16.840.1.114222.4.11.7480'	// https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7480
valueset "Arbovirus Tests": '2.16.840.1.114222.4.11.4120' // https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.4120
valueset "Chikungunya Tests": '2.16.840.1.114222.4.11.7339' // https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7339
valueset "Dengue Tests": '2.16.840.1.114222.4.11.4141' // https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.4141
valueset "Zika Virus IgM ELISA Results": '2.16.840.1.114222.4.11.7476' // This value set is intended for use in electronic laboratory reporting based on the results received from the laboratory.  The laboratory may also report a quantitative titer if applicable.	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7476
valueset "Zika Virus Neutralizing Antibody Results": '2.16.840.1.114222.4.11.7477' // This value set is intended for use in electronic laboratory reporting based on the results received from the laboratory.  The laboratory may also report a quantitative titer if applicable.	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7477
valueset "Arbovirus Test Results": '2.16.840.1.114222.4.11.4003' //	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.4003
valueset "Chikungunya Test Results": '2.16.840.1.114222.4.11.7343' // This value set is intended for use in electronic laboratory reporting based on the results received from the laboratory.  The laboratory may also report a quantitative titer if applicable.	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.7343
valueset "Dengue Test Results": '2.16.840.1.114222.4.11.4025' // This value set is intended for use in electronic laboratory reporting based on the results received from the laboratory.  The laboratory may also report a quantitative titer if applicable.	https://phinvads.cdc.gov/vads/ViewValueSet.action?oid=2.16.840.1.114222.4.11.4025

code "CDE: Resident of or Frequent Traveler to Zika Area": 'CDE: Resident of or Frequent Traveler to Zika Area' from "Example Questionnaires"
code "CDE: Recent Travel to Zika Area": 'CDE: Recent Travel to Zika Area' from "Example Questionnaires"
code "CDE: Time Since Returned From Travel": 'CDE: Time Since Returned From Travel' from "Example Questionnaires"
code "CDE: Recent Sexual Encounter With Traveler to Zika Area": 'CDE: Recent Sexual Encounter With Traveler to Zika Area' from "Example Questionnaires"
code "CDE: Time Since Sexual Encounter": 'CDE: Time Since Sexual Encounter' from "Example Questionnaires"
code "CDE: Planned Travel to Zika Area": 'CDE: Planned Travel to Zika Area' from "Example Questionnaires"

parameter "Current Encounter" Encounter

context Patient

define "Pregnancy Conditions":
  [Condition: "Pregnancy"] C
    where C.clinicalStatus.value = 'active'
      and C.verificationStatus.value = 'confirmed'
      and C.onset.value <= Today()
      and C.abatement.value > Today()

define "Is Patient Pregnant":
  Patient.gender.value = 'female'
    and exists ("Pregnancy Conditions")

define "Zika Exposure Assessment":
  Code 'Zika Virus Exposure Assessment' from "Example Questionnaires"

define "Zika Exposure Assessment Result":
  First(
    [Observation: "Zika Exposure Assessment"] O
      where O.status.value = 'final'
    	// and O."context".reference.value = "Current Encounter".id.value // TODO: fix
      sort by effective.value desc
  )

define "Has Zika Exposure Assessment":
  "Zika Exposure Assessment Result" is not null

define "Zika Symptoms":
  [Condition: "Zika Virus Signs and Symptoms"] C
    where C.clinicalStatus.value = 'active'
      and C.verificationStatus.value = 'confirmed'
      // and C."context".reference.value = "Current Encounter".id.value // TODO: fix

define "Has Zika Symptoms":
  exists "Zika Symptoms"

define "No Zika Symptoms":
  not "Has Zika Symptoms"

define "Yes": { 'Yes' }

define "Resident of or Frequent Traveler to Zika Area":
  exists (
    "Zika Exposure Assessment Result".component C
      // TODO: Need to streamline, this ought to have worked, not sure why it didn't (without the coding[0] access)
      where CodingToCode(C.code.coding[0]) = "CDE: Resident of or Frequent Traveler to Zika Area"
        and C.value.value in "Yes"
  )

define "Recent Travel to Zika Area":
  exists (
    "Zika Exposure Assessment Result".component C
      where CodingToCode(C.code.coding[0]) = "CDE: Recent Travel to Zika Area"
        and C.value.value in "Yes"
  )

define "Time Since Returned From Travel":
  singleton from (
    "Zika Exposure Assessment Result".component C
      where CodingToCode(C.code.coding[0]) = "CDE: Time Since Returned From Travel"
      return C.value as Quantity
  )

define "Recent Sexual Encounter With Traveler to Zika Area":
  exists (
    "Zika Exposure Assessment Result".component C
      where CodingToCode(C.code.coding[0]) = "CDE: Recent Sexual Encounter With Traveler to Zika Area"
        and C.value.value in "Yes"
  )

define "Time Since Sexual Encounter":
  singleton from (
    "Zika Exposure Assessment Result".component C
      where CodingToCode(C.code.coding[0]) = "CDE: Time Since Sexual Encounter"
      return C.value as Quantity
  )

define "Time Since Possible Exposure":
  Coalesce("Time Since Returned From Travel", "Time Since Sexual Encounter")

define "Planned Travel to Zika Area":
  exists (
    "Zika Exposure Assessment Result".component C
      where CodingToCode(C.code.coding[0]) = "CDE: Planned Travel to Zika Area"
        and C.value.value in "Yes"
  )

define "Has Possible Zika Exposure":
  "Resident of or Frequent Traveler to Zika Area"
    or "Recent Travel to Zika Area"
    or "Recent Sexual Encounter With Traveler to Zika Area"

define "Zika Symptom Onset":
  First(
    "Zika Symptoms" S
      sort by case when onset.value is DateTime then onset.value else ToDateTime(onset.value) end
  ).onset

define "Weeks since Symptom Onset":
	weeks between "Zika Symptom Onset".value and Today()

define "Time Since Symptom Onset":
  System.Quantity { value: if "Weeks since Symptom Onset" is null then 0 else "Weeks since Symptom Onset", unit: 'wk' }

define "Should Administer Zika Virus Exposure Assessment":
  not ("Has Zika Exposure Assessment")

define "Should Order Serum + Urine rRT-PCR Test":
  ("Has Possible Zika Exposure" and "Has Zika Symptoms" and "Time Since Symptom Onset" < 2 weeks)
    or ("No Zika Symptoms" and if "Time Since Possible Exposure" is null then false else ToQuantity("Time Since Possible Exposure") < 2 weeks)

define "Should Order Serum Zika Virus IgM + Dengue Virus IgM":
  ("Has Possible Zika Exposure" and "Has Zika Symptoms" and "Time Since Symptom Onset" in Interval[2 weeks, 12 weeks))
    or ("Resident of or Frequent Traveler to Zika Area" and "No Zika Symptoms")
    or ("No Zika Symptoms" and if "Time Since Possible Exposure" is null then false else ToQuantity("Time Since Possible Exposure") in Interval[2 weeks, 12 weeks))

define "Should Consider IgM Antibody Testing":
  ("Has Possible Zika Exposure" and "Has Zika Symptoms" and "Time Since Symptom Onset" >= 12 weeks)
    or ("No Zika Symptoms" and if "Time Since Possible Exposure" is null then false else ToQuantity("Time Since Possible Exposure") >= 12 weeks)

define "Should Provide Mosquito Prevention and Contraception Advice":
  "Planned Travel to Zika Area"

define function CodingToCode(coding FHIR.Coding):
	System.Code {
		code: coding.code.value,
		system: coding.system.value,
		version: coding.version.value,
		display: coding.display.value
	}

define function ToQuantity(quantity FHIR.Quantity):
	System.Quantity {
    	value: quantity.value.value,
      	unit: quantity.unit.value
    }