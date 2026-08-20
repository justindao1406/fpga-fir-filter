from scipy.signal import firwin
from fixed_point import float_to_q15

sample_rate = 48000      # 48 kHz
cutoff_frequency = 5000  # Remove frequencies above roughly 5 kHz
number_of_taps = 15

coefficients = firwin(number_of_taps, cutoff_frequency, fs=sample_rate, window='hamming')
print("Coefficient sum:", sum(coefficients))

coefficients_q15 = []

for c in coefficients:
    coefficients_q15.append(float_to_q15(c))

print("coefficients in Q1.15 format: ", coefficients_q15)

# predicted_outputs used for fir_filter_tb in Vivado

predicted_outputs = []

for c in coefficients_q15:
    predicted_outputs.append((c*32767)>>15)

print("predicted outputs used for fir_filter tb: ", predicted_outputs)


