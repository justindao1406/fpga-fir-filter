import numpy as np
import matplotlib.pyplot as plt
from generate_coefficients import coefficients_q15
from fixed_point import float_to_q15, fir_filter_q15, q15_to_float
from pathlib import Path

# input signal (sine waves)

sample_rate = 48000
duration = 0.01
samples = int(sample_rate * duration)

time = (np.arange(samples)) / sample_rate # Each element is timestamp of 1 sample

amplitude = 0.4
lo_freq = 1000
hi_freq = 10000

lo_sig = amplitude*(np.sin(2*(np.pi)*(lo_freq)*time))
hi_sig = amplitude*(np.sin(2*(np.pi)*(hi_freq)*time))
input_sig = lo_sig + hi_sig

# Convert to q1.15

input_sig_q15 = []
for sample in input_sig:
    input_sig_q15.append(float_to_q15(sample))

output_sig_q15 = fir_filter_q15(input_sig_q15, coefficients_q15)

# Convert output to float

output_sig = []
for sample in output_sig_q15:
    output_sig.append(q15_to_float(sample))

# Loading up the memory data file for Vivado tb

data_dir = Path(__file__).resolve().parent.parent / "data"

with open(data_dir / "input_samples.mem", "w") as file:
    for sample in input_sig_q15:
        hex_sample = sample & 0xFFFF
        file.write(f"{hex_sample:04x}\n")

with open(data_dir / "predicted_outputs.mem", "w") as file:
    for output in output_sig_q15:
        hex_output = output & 0xFFFF
        file.write(f"{hex_output:04x}\n")

# plotting

fig_in, ax_in = plt.subplots()
ax_in.plot(time, input_sig)

ax_in.set(xlabel="time in s", ylabel="amplitude", title="combined 1kHz and 10kHz input signal")

ax_in.grid()
fig_in.savefig("input.png")


fig_out, ax_out = plt.subplots()
ax_out.plot(time, output_sig)

ax_out.set(xlabel="time in s", ylabel="amplitude", title="combined 1kHz and 10kHz filtered ouput signal")

ax_out.grid()
fig_out.savefig("output.png")

plt.show()