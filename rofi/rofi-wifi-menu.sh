# Añadimos --rescan no para velocidad
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list --rescan no | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
    toggle="󰖩  Enable Wi-Fi"
fi

# Añadimos opción de Rescan manual
rescan="󰑓  Manual Rescan"

# Use rofi to select wifi network
chosen_network=$(echo -e "$toggle\n$rescan\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )

# Get name of connection
read -r chosen_id <<< "${chosen_network:3}"

if [ "$chosen_network" = "" ]; then
    exit
elif [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
    nmcli radio wifi on
elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
    nmcli radio wifi off
elif [ "$chosen_network" = "🔄  Manual Rescan" ]; then
    # Aquí sí forzamos el escaneo y reabrimos el script recursivamente
    notify-send "Wi-Fi" "Escaneando redes... Espere 5s"
    nmcli device wifi list --rescan yes > /dev/null
    exec "$0" # Se vuelve a ejecutar a sí mismo tras el escaneo
else
    # Lógica de conexión original...
    success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
    saved_connections=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else
        if [[ "$chosen_network" =~ "" ]]; then
            wifi_password=$(rofi -dmenu -p "Password: " )
        fi
        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
    fi
fi
