#!/bin/sh
. /usr/share/libubox/jshn.sh

def_cfg=`uci get gateway.general.gwcfg`
subband=`uci get gateway.general.subband`
gwid=`uci get gateway.general.GWID`
provider=`uci get gateway.general.provider`
server=`uci get gateway.general.${provider}_server`
upp=`uci get gateway.general.port`
dpp=`uci get gateway.general.dwport`
stat=`uci get gateway.general.stat`

model=`cat /tmp/iot/model.txt`

#################################################
# "gateway_conf": {
#         "server_address": "router.eu.thethings.network",
#         "serv_port_up": 1700,
#         "serv_port_down": 1700,
#         "keepalive_interval": 5,
#         "stat_interval": 30,
#         "push_timeout_ms": 30,
#         "forward_crc_valid": true,
#         "forward_crc_error": false
#         }
#################################################

gen_gw_cfg() {
    json_init
    json_add_object gateway_conf
    json_add_string "gateway_ID" "$gwid"
    json_add_string "server_address" "$server"
    json_add_int "serv_port_up" "$upp"
    json_add_int "serv_port_down" "$dpp"
    json_add_int "stat_interval" "$stat"
    json_add_boolean "forward_crc_valid" 1
    json_add_boolean "forward_crc_error" 0
	if [ $model == "DLOS8" ];then	
		json_add_string "gps_tty_path" "/dev/ttyUSB0"
	fi
    json_close_object
    json_dump  > /etc/lora/local_conf.json
}

echo_chan_if() {
    echo "SX1301 Channels frequency" > /etc/lora/desc
    echo "---------------------------------------" >> /etc/lora/desc

    json_load_file "/etc/lora/global_conf.json"
    json_select SX1301_conf
    for i in `seq 0 7`
    do
        json_select chan_multiSF_$i
        json_get_var desc desc
        json_select ..
        echo "chan_multSF_$i" >> /etc/lora/desc 
        echo "$desc" >> /etc/lora/desc
        echo "---------------------------------------" >> /etc/lora/desc
    done

    json_select chan_Lora_std
    json_get_var desc desc
    json_select ..
    echo "chan_Lora_std" >> /etc/lora/desc
    echo "$desc" >> /etc/lora/desc
    echo "---------------------------------------" >> /etc/lora/desc

    json_cleanup

}

if [ "$def_cfg" = "AU" ] || [ "$def_cfg" = "US" ] ;then
	def_cfg="$def_cfg-$subband"
fi


if [ $model == "LG308" ] || [ $model == "DLOS8" ];then
	chip="301"
elif [ $model == "LPS8" ];then
	chip="308"
fi

if [ -f /etc/lora/cfg-$chip/"$def_cfg"-global_conf.json ] 
then 
    gen_gw_cfg
    cp -rf /etc/lora/cfg-$chip/"$def_cfg"-global_conf.json /etc/lora/global_conf.json
    echo_chan_if
else
    rm -rf /etc/lora/local_conf.json
    json_init
    json_add_object SX1301_conf
    json_add_boolean lorawan_public 1
    json_add_int clksrc 1
    json_add_int antenna_gain 0

###########################################
## radio_0 and radio_1
##### "enable": true,
##### "type": "SX1257",
##### "freq": 867500000,
##### "rssi_offset": -166.0,
##### "tx_enable": true,
##### "tx_freq_min": 863000000,
##### "tx_freq_max": 870000000
##########################################

    for i in 0 1
    do
        eval radio${i}_enable=`uci get gateway.general.radio${i}_enable`
        json_add_object radio_"$i"
        eval json_add_boolean enable \$radio${i}_enable
        eval cmp="\$radio${i}_enable"
        if [ "$cmp" = "1" ]; then
            eval radio${i}_freq=`uci get gateway.general.radio${i}_freq`
            eval radio${i}_tx=`uci get gateway.general.radio${i}_tx`
            json_add_string "type" "SX1257"
            eval json_add_int freq \$radio${i}_freq
            json_add_double rssi_offset -166.0
            eval json_add_boolean tx_enable \$radio${i}_tx
            eval cmp="\$radio${i}_tx"
            if [ "$cmp" = "1" ]; then
                eval radio${i}_txfreq_min=`uci get gateway.general.radio${i}_txfreq_min`
                eval radio${i}_txfreq_max=`uci get gateway.general.radio${i}_txfreq_max`
                eval json_add_int tx_freq_min \$radio${i}_txfreq_min
                eval json_add_int tx_freq_max \$radio${i}_txfreq_max
            fi
        fi
        json_close_object
    done
    

#############################################
##"chan_multiSF_%i": {
##        "desc": "Lora MAC, 125kHz, all SF, 868.1 MHz",
##        "enable": true,
##        "radio": 1,
##       "if": -400000
##},
#############################################

    echo "SX1301 Channels frequency" > /etc/lora/desc

    for i in `seq 0 7`
    do
        eval chan${i}_enable=`uci get gateway.general.chan${i}_enable`
        json_add_object chan_multiSF_"$i"
        eval json_add_boolean enable \$chan${i}_enable
        eval cmp="\$chan${i}_enable"
        if [ "$cmp" = "1" ]; then
            eval chan${i}=`uci get gateway.general.chan${i}`
            eval chan${i}_radio=`uci get gateway.general.chan${i}_radio`
            eval radio_index=\$chan${i}_radio                
            eval radio_freq=\$radio${radio_index}_freq
            eval json_add_int "radio" \$chan${i}_radio
            eval json_add_int "if" \$chan${i}
            eval chan_if=\$chan${i}
            chan_freq=`expr $radio_freq + $chan_if`
            echo "---------------------------------------" >> /etc/lora/desc
            echo "chan_multiSF_$i" >> /etc/lora/desc
            echo "LORA MAC, 125kHz, all SF, $chan_freq Hz" >> /etc/lora/desc
        fi
        json_close_object
    done
        
#############################################
# "chan_Lora_std": {
#             "desc": "Lora MAC, 250kHz, SF7, 868.3 MHz",
#             "enable": true,
#             "radio": 1,
#             "if": -200000,
#             "bandwidth": 250000,
#             "spread_factor": 7
#             },
# "chan_FSK": {
#             "desc": "FSK 50kbps, 868.8 MHz",
#             "enable": true,
#             "radio": 1,
#             "if": 300000,
#             "bandwidth": 125000,
#             "datarate": 50000
#             }
#############################################
    eval lorachan_enable=`uci get gateway.general.lorachan_enable`
    json_add_object chan_Lora_std
    eval json_add_boolean enable $lorachan_enable
    if [ "$lorachan_enable" = "1" ]; then
        lorachan_radio=`uci get gateway.general.lorachan_radio`
        lorachan=`uci get gateway.general.lorachan`
        lorachan_sf=`uci get gateway.general.lorachan_sf`
        lorachan_bw=`uci get gateway.general.lorachan_bw`
        json_add_int "radio" $lorachan_radio
        json_add_int "if" $lorachan
        json_add_int "bandwidth" $lorachan_bf
        json_add_int "spread_factor" $lorachan_sf
        eval radio_freq=\$radio${lorachan_radio}_freq
        chan_freq=`expr $radio_freq - $lorachan`
        echo "---------------------------------------" >> /etc/lora/desc
        echo "chan_Lora_std" >> /etc/lora/desc
        echo "LORA MAC, $lorachan_bf, $lorachan_sf, $chan_freq Mhz" >> /etc/lora/desc
    fi
    json_close_object

    json_add_object chan_FSK
    json_add_boolean "enable"  "1" 
    json_add_int "radio"  "1" 
    json_add_int "if"  "300000" 
    json_add_int "bandwidth"  "125000" 
    json_add_int "datarate"  "125000" 
    json_close_object

#################################################
# "tx_lut_": {
#             "desc": "TX gain table, index 14",
#             "pa_gain": 3,
#             "mix_gain": 12,
#             "rf_power": 26,
#             "dig_gain": 0
#             }
#################################################

    json_add_object tx_lut_0
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "9" 
    json_add_int "rf_power"  "12" 
    json_add_int "dig_gain"  "2" 
    json_close_object

    json_add_object tx_lut_1
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "9" 
    json_add_int "rf_power"  "13" 
    json_add_int "dig_gain"  "1" 
    json_close_object

    json_add_object tx_lut_2
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "10" 
    json_add_int "rf_power"  "14" 
    json_add_int "dig_gain"  "2" 
    json_close_object

    json_add_object tx_lut_3
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "10" 
    json_add_int "rf_power"  "15" 
    json_add_int "dig_gain"  "1" 
    json_close_object

    json_add_object tx_lut_4
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "10" 
    json_add_int "rf_power"  "16" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_5
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "11" 
    json_add_int "rf_power"  "17" 
    json_add_int "dig_gain"  "1" 
    json_close_object

    json_add_object tx_lut_6
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "11" 
    json_add_int "rf_power"  "18" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_7
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "12" 
    json_add_int "rf_power"  "19" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_8
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "13" 
    json_add_int "rf_power"  "20" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_9
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "14" 
    json_add_int "rf_power"  "21" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_10
    json_add_int "pa_gain"  "2" 
    json_add_int "mix_gain"  "15" 
    json_add_int "rf_power"  "22" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_11
    json_add_int "pa_gain"  "3" 
    json_add_int "mix_gain"  "11" 
    json_add_int "rf_power"  "23" 
    json_add_int "dig_gain"  "1" 
    json_close_object

    json_add_object tx_lut_12
    json_add_int "pa_gain"  "3" 
    json_add_int "mix_gain"  "12" 
    json_add_int "rf_power"  "24" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_13
    json_add_int "pa_gain"  "3" 
    json_add_int "mix_gain"  "14" 
    json_add_int "rf_power"  "25" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_14
    json_add_int "pa_gain"  "3" 
    json_add_int "mix_gain"  "14" 
    json_add_int "rf_power"  "26" 
    json_add_int "dig_gain"  "0" 
    json_close_object

    json_add_object tx_lut_15
    json_add_int "pa_gain"  "3" 
    json_add_int "mix_gain"  "14" 
    json_add_int "rf_power"  "27" 
    json_add_int "dig_gain"  "0" 
    json_close_object
	
    #close json object SX1301_conf
    json_close_object

    json_add_object gateway_conf
    json_add_string "gateway_ID" "$gwid"
    json_add_string "server_address" "$server"
    json_add_int "serv_port_up" "$upp"
    json_add_int "serv_port_down" "$dpp"
    json_add_int "stat_interval" "$stat"
    json_add_boolean "forward_crc_valid" 1
    json_add_boolean "forward_crc_error" 0
	if [ $model == "DLOS8" ];then	
		json_add_string "gps_tty_path" "/dev/ttyUSB0"
	fi
    json_close_object

    json_dump  > /etc/lora/global_conf.json


fi