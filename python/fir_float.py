def fir_filter(samples, coefficients):
    output = [] # output is an array of y[0], y[1], y[2]... etc

    for i in range(len(samples)):
        accumulator = 0

        for j in range(len(coefficients)):
            position = i - j

            if position >= 0:
                accumulator += coefficients[j]*samples[position]

        output.append(accumulator)

    return output

        