# homebus-dremel

This is a simple HomeBus data source which publishes printer status for Dremel 3D printers.

## Usage

On its first run, `homebus-dremel` needs to know how to find the HomeBus provisioning server.

```
bundle exec homebus-dremel -b homebus-server-IP-or-domain-name -P homebus-server-port
```

The port will usually be 80 (its default value).

Once it's provisioned it stores its provisioning information in `.env.provisioning`.

`homebus-dremel` also needs to know:

- URL for Dremel dashboard


## Notes

JSON from the Dremel looks like this:

```
{
    "BedTempTarget": 70,
    "ErrorCode": 200,
    "FilamentType": 6,
    "FirwareVersion": "v3.0_R02.05.03",
    "Message": "success",
    "NozzleTemp": 249,
    "NozzleTempTarget": 250,
    "PreheatBed": 0,
    "PreheatNozzle": 0,
    "PrinterBedMessage": "Bed 0-100 ℃",
    "PrinterCamera": "http://192.168.15.24:10123/?action=stream",
    "PrinterFiles": 20,
    "PrinterMicrons": "50-300 microns",
    "PrinterNozzleMessage": "Nozzle 0-280 ℃",
    "PrinterStatus": "printing",
    "PrintererAvailabelStorage": 90,
    "PrintingFileName": "D32_Dry_Erase_Holder.gcode",
    "PrintingFilePic": "/tmp/mnt/dev/mmcblk0p3/modelFromDevice/pic/D32_Dry_Erase_Holder_gcode.bmp",
    "PrintingProgress": 26.899999999999999,
    "RemainTime": 26877,
    "SerialNumber": "807044685",
    "UsageCounter": "116"
}

{
    "BedTemp": 30,
    "BedTempTarget": 0,
    "ErrorCode": 200,
    "FilamentType": 6,
    "FirwareVersion": "v3.0_R02.05.03",
    "Message": "success",
    "NozzleTemp": 34,
    "NozzleTempTarget": 0,
    "PreheatBed": 0,
    "PreheatNozzle": 0,
    "PrinterBedMessage": "Bed 0-100 ℃",
    "PrinterCamera": "http://192.168.15.24:10123/?action=stream",
    "PrinterFiles": 20,
    "PrinterMicrons": "50-300 microns",
    "PrinterNozzleMessage": "Nozzle 0-280 ℃",
    "PrinterStatus": "idle",
    "PrintererAvailabelStorage": 91,
    "PrintingFileName": "",
    "PrintingFilePic": "",
    "PrintingProgress": 0,
    "RemainTime": 0,
    "SerialNumber": "807044685",
    "UsageCounter": "128"
}
```
