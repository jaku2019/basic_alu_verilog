#!/bin/bash

# Zatrzymanie skryptu w przypadku błędu
set -e

# --- BANNER STARTOWY ---
clear  # Opcjonalnie: czyści terminal przed wyświetleniem
echo "=============================================="
echo "             POLIBUDEX sck helper             "
echo "              © POLIBUDEX 2025                "
echo "=============================================="
echo ""
echo "Wciśnij ENTER, by rozpocząć..."

# Czekanie na wciśnięcie klawisza Enter
read

echo "--- [1/4] Rozpoczynam kompilację i symulację modelu RTL ---"
sleep 2
# Kompilacja modelu behawioralnego
iverilog -o sim.out MODEL/library_modules.v MODEL/top.v TESTBENCH/simulation_modules.v TESTBENCH/testbench.v

# Uruchomienie symulacji
vvp sim.out

# Zmiana nazwy pliku z przebiegami
if [ -f "SIGNALS.vcd" ]; then
    mv SIGNALS.vcd SIGNALS_pre.vcd
    echo "Model RTL: Wygenerowano SIGNALS_pre.vcd"
else
    echo "BŁĄD: Nie znaleziono pliku SIGNALS.vcd po symulacji RTL!"
    exit 1
fi

echo -e "\n--- [2/4] Rozpoczynam syntezę Yosys ---"
sleep 2
# Generacja Netlisty
yosys -p "read_verilog MODEL/library_modules.v; read_verilog MODEL/top.v; hierarchy -top TOP; hierarchy -check; proc; opt; fsm; opt; memory; opt; techmap; opt; clean; stat; write_verilog -noattr synth_output.v"

echo -e "\n--- [3/4] Rozpoczynam symulację po syntezie (Post-Synthesis) ---"
sleep 2
# Sprawdzenie czy istnieje zmodyfikowany testbench
if [ ! -f "TESTBENCH/testbench_post_synth.v" ]; then
    echo "BŁĄD: Brak pliku TESTBENCH/testbench_post_synth.v. Utwórz go ręcznie przed uruchomieniem skryptu."
    exit 1
fi

# Kompilacja testbencha po syntezie
iverilog -s testbench -o post_synth.vvp synth_output.v TESTBENCH/simulation_modules.v TESTBENCH/testbench_post_synth.v

# Uruchomienie symulacji po syntezie
vvp post_synth.vvp

# Zmiana nazwy drugiego pliku z przebiegami
if [ -f "SIGNALS.vcd" ]; then
    mv SIGNALS.vcd SIGNALS_post.vcd
    echo "Synteza: Wygenerowano SIGNALS_post.vcd"
else
    echo "BŁĄD: Nie znaleziono pliku SIGNALS.vcd po symulacji Post-Synth!"
    exit 1
fi


echo -e "\n--- [4/4] Otwieranie GTKWave do porównania przebiegów ---"
sleep 2
# Uruchomienie GTKWave w tle
gtkwave SIGNALS_pre.vcd SIGNALS_post.vcd &

echo "Gotowe."