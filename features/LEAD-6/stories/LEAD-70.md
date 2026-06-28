# Story - LEAD-70: Verify sourcetype = "Everlytic" & "want2Talk2PSI: False" in One Connect DAE Platform 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-70` |
| **Type** | `任务` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-6` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
Everlytic data
STTM mapping
{
  "leadId": "dfdgd4020910083412332",
  "contactName": {
    "fullName": "PARTYAP VTEN",
    "firstName": "PARTYAP",
    "surname": "VTEN"
  },
  "leadPersonalInfo": {
    "gender": "FEMALE",
    "income": 6000,
    "contactInfo": {
      "phone": {
        "number": "0761143026"
      },
      "email": "KCARELSE@OLDMUTUAL.COM"
    }
  },
  "source": {
    "campaignID": "20240423002",
    "code": "Everlytic",         
    "displayName": "Everlytic",   
    "type": "Everlytic"          
  },
  "region": {
    "country": "ZA"
  },
  "customerInfo": {
    "customerID": "K1LNXE8RXKQRY",
    "psi": {
      "salesCode": "313873"
    }
  },
  "leadIntension": {
    "preferredTime": {
      "displayName": "7-10AM"
    },
    "needs": {
      "comment": "INVESTMENT,RETIREMENT,FUNERAL"
    }
  }
}

Please verify in the OC Engagement Platform:
* * When want2Talk2PSI=False or salescode= "",  Will the lead be dispatched or not?
If want2Talk2PSI=false or salesCode= "", and it is handled by URLE, where will it be routed?

Please check this leadid (data from prod)
{"id": null, "leadId": "18998973", "region": {"city": null, "suburb": null, "address": null, "country": "ZA", "province": null, "postalCode": null}, "source": {"code": "Everlytic", "type": "Everlytic", "formId": "0", "channelId": "0", "campaignID": "20250214001", "displayName": "Everlytic", "productName": ""}, "contactName": {"title": null, "surname": "Cagwe Adams", "fullName": "Ntombekaya Cagwe Adams", "initials": null, "firstName": "Ntombekaya"}, "customerInfo": {"PSI": {"SalesCode": "", "digitalId": null, "BrokerCode": null, "channelCode": null, "segmentCode": null, "stuffNumber": null, "SalesCodeType": null, "performanceScore": 0}, "compclK": null, "partyId": null, "idNumber": null, "customerID": "K0DTHNWCXQK1M", "want2Talk2PSI": true}, "leadIntension": {"needs": {"code": null, "comment": "Hi I'm not happy I'm about to cancel all my policies with your company ", "displayName": "Hi I'm not happy I'm about to cancel all my policies with your company "}, "priority": null, "createTime": null, "engagement": null, "preferredTime": {"code": null, "displayName": ""}, "selectedAdvisor": {"branchId": null, "SalesCode": null, "digitalId": null, "staffCode": null, "BrokerCode": null, "StuffNumber": null, "channelCode": null, "segmentCode": null, "worksiteCode": null, "SalesCodeType": null, "performanceScore": 0}, "addtionalInformation": null}, "retentionLead": {"formId": "0", "sourceId": null, "statusId": "0", "channelId": "0", "isMaturity": "false", "leadTypeId": "0", "maturityDate": null, "maturityValue": null, "policyDetails": null, "premiumquency": null, "isAutoDistribute": null}, "campaignPFToMFC": "1", "addtionalDetails": null, "intermediateCode": null, "leadPersonalInfo": {"gender": null, "income": 0.0, "language": null, "incomeBand": {"level": 2, "displayName": "<30k per Month"}, "contactInfo": {"email": ntombekaya.cagwe-adams@dcs.gov.za, "phone": {"num": "0738087837", "type": null, "countryNum": "+27"}}, "dateOfBirth": null}}


## 🎯 Acceptance Criteria (验收标准)
*未明确配置 Acceptance Criteria*

## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-70_comments.md)**

