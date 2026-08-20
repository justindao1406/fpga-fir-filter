def float_to_q15(value):
    # convert real number -> stored integer
    res = round(value * 2**(15)) 
    if res > 32767:
        return 32767
    elif res < -32768:
        return -32768
    else:
        return res

def q15_to_float(stored):
    # convert stroed integer -> real number
    res = stored / (2**(15))
    return res

def fir_filter_q15(samples_q15, coefficients_q15):
    # Using stored integers as values
    output = []   

    for i in range(len(samples_q15)):
        accumulator = 0

        for j in range(len(coefficients_q15)):
            position = i - j

            if position >= 0:
                accumulator += coefficients_q15[j]*samples_q15[position]

        accumulator = accumulator >> 15

        if accumulator > 32767:
            accumulator = 32767
        elif accumulator < -32768:
            accumulator = -32768

        output.append(accumulator)

    return output
