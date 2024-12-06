Map<String, dynamic> jsonInput = {
  "SPaRASInput.json": {
    "systemSettings": {
      "Record_Version": 2,
      "Record_Revision": 1,
      "Board_ID": 1,
      "Firmware_ID": 4,
      "currDate": [24, 4, 16],
      "currTime": [18, 0, 0],
      "encryptionCert": "S30G2H3y34GVGi6FG876ghYbNm74X3v1"
    },
    "medinfo": {
      "dosage": 500,
      "quantity": 32,
      "expiry": [25, 4, 16]
    },
    "sensorSettings": {
      "ConfigID": "1Minute",
      "temperature": {
        "active": 1,
        "recCon": 2,
        "threshold1": 0,
        "threshold2": 60,
        "sampleRate": 60
      },
      "pressure": {
        "active": 1,
        "recCon": 4,
        "threshold1": 260,
        "threshold2": 1260,
        "sampleRate": 60
      },
      "luminosity": {
        "active": 0,
        "recCon": 4,
        "threshold1": 0,
        "sampleRate": 0
      },
      "imuacc": {"active": 0, "recCon": 4, "threshold1": 32000},
      "orientation": {
        "active": 0,
        "recCon": 4,
        "threshold1": 0,
        "threshold2": 6
      },
      "tiltrec": {"active": 0, "recCon": 1, "threshold1": 0, "threshold2": 90}
    }
  }
};
