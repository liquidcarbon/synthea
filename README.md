# SyntheticMass
Analysis of [Synthea SyntheticMass](https://synthea.mitre.org/downloads) (open-source synthetic patient population)

## Predicting Hypertension

The goal of this exercise is to predict the probability that a patient has hypertension (diagnosis code 38341003) on a given date.

On inspecting the data, we find that 98% of patients "developed" hypertension between the ages of 18 and 20.  The likely reason for that can be found in the source code for SyntheticMass.  The [clinical care map](https://github.com/synthetichealth/synthea/blob/master/src/main/resources/modules/hypertension.json) used to model hypertension specifies that the "onset" and progression will take place within several months of first wellness encounter (anyone under 18 is excluded).

My prediction is this: the probability that anyone has hypertension on a given date is 15% for people over 20 years old.  There are no other features to engineer.  This is due to how this data is generated.  The proposed exercise is not very meaningful on the provided dataset.

The inspection of `observations.csv` corroborates this notion: 85% of systolic blood pressure measurements are uniformly distributed between 100 and 139 mmHg, and the other 15% uniformly distributed between 140 and 200 mmHg (leading to the diagnosis of hypertension).  Looking longitudinally, we can see that one does not "develop" hypertension: they either have it or not:

```
cat observations.csv | grep Systolic | awk -F, '{print $2","$1","$(NF-1)}' | sort | head -1000

0005923b-f692-4608-ac67-ed12ca51e596,2011-05-12,166.0
0005923b-f692-4608-ac67-ed12ca51e596,2012-06-08,142.0
0005923b-f692-4608-ac67-ed12ca51e596,2013-05-28,167.0
0005923b-f692-4608-ac67-ed12ca51e596,2014-04-09,188.0
0005923b-f692-4608-ac67-ed12ca51e596,2015-03-13,196.0
0005923b-f692-4608-ac67-ed12ca51e596,2016-01-25,200.0

0005fffa-4b7c-4952-91ac-19d854e089eb,2011-06-15,127.0
0005fffa-4b7c-4952-91ac-19d854e089eb,2013-12-08,136.0
0005fffa-4b7c-4952-91ac-19d854e089eb,2016-11-25,105.0

0006b2a0-f823-460f-9682-9a52fa7aec34,2011-06-01,141.0
0006b2a0-f823-460f-9682-9a52fa7aec34,2013-02-18,166.0
0006b2a0-f823-460f-9682-9a52fa7aec34,2015-03-21,187.0
0006b2a0-f823-460f-9682-9a52fa7aec34,2016-02-21,173.0
0006b2a0-f823-460f-9682-9a52fa7aec34,2017-03-11,143.0

0007f2f0-f663-4455-a438-d3e06b4590b6,2012-05-11,105.0
0007f2f0-f663-4455-a438-d3e06b4590b6,2014-05-18,125.0
0007f2f0-f663-4455-a438-d3e06b4590b6,2015-11-06,119.0

000863b8-0dd6-43b0-8f34-47277da5cd7c,2010-06-05,191.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2011-05-29,173.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2012-05-06,146.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2013-05-05,162.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2014-04-10,163.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2015-04-05,158.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2016-04-04,183.0
000863b8-0dd6-43b0-8f34-47277da5cd7c,2017-01-12,199.0

0009366f-5e37-423d-9c28-ff61f93ebdf8,2010-11-01,121.0
0009366f-5e37-423d-9c28-ff61f93ebdf8,2014-04-26,115.0
0009366f-5e37-423d-9c28-ff61f93ebdf8,2017-04-05,129.0

00094a4e-5624-4e0e-a4be-991a4072ad0a,2011-11-24,102.0
00094a4e-5624-4e0e-a4be-991a4072ad0a,2013-11-29,101.0
00094a4e-5624-4e0e-a4be-991a4072ad0a,2015-11-11,108.0
00094a4e-5624-4e0e-a4be-991a4072ad0a,2017-05-14,139.0
```
