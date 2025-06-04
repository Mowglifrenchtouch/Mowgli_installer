#!/bin/bash
# detection_gps_rtk.sh : détection du GPS (/dev/gps) et du mountpoint RTK

detect_gps_rtk() {
  # Détection GPS
  if [[ -e /dev/gps ]]; then
    GPS_STATUS="✅ GPS détecté (/dev/gps)"
  else
    GPS_STATUS="❌ GPS non détecté"
  fi

  # Détection du mountpoint RTK
  MOUNTPOINT=$(docker logs mowgli-openmower 2>&1 | grep -m1 "mountpoint" | awk -F ': ' '{print $2}')
  if [[ -n "$MOUNTPOINT" ]]; then
    RTK_STATUS="📡 Mountpoint RTK utilisé : $MOUNTPOINT"
  else
    RTK_STATUS="📡 Mountpoint RTK non détecté"
  fi
}

afficher_infos_gps_rtk() {
  echo "$GPS_STATUS"
  echo "$RTK_STATUS"
}
