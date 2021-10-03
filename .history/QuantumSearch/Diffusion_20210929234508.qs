namespace Quantum.QuantumSearch {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Measurement;


    operation Diffusion(inputQubits : Qubit[]) : Unit {
        within {
            ApplyToEachA(H, inputQubits);
            ApplyToEachA(X, inputQubits);
        } apply {
            Controlled Z(Most(inputQubits), Tail(inputQubits));
        }
    }

    operation RunGroversSearch(register : Qubit[], phaseOracle : (Qubit[]) => Unit is Adj, iterations : Int) : Unit {
        ApplyToEach(H, register);
        for _ in 1 .. iterations {
            phaseOracle(register);
            Diffusion(register);
        }
    }

    operation MarkDivisor (
        dividend : Int,
        divisorRegister : Qubit[],
        target : Qubit
    ) : Unit is Adj + Ctl {
        let size = BitSizeI(dividend);
        use dividendQubits = Qubit[size];
        use resultQubits = Qubit[size];

        let xs = LittleEndian(dividendQubits);
        let ys = LittleEndian(divisorRegister);
        let result = LittleEndian(resultQubits);

        within {
            ApplyXorInPlace(dividend, xs);
            DivideI(xs, ys, result);
            ApplyToEachA(X, xs!);
        } apply {
            Controlled X(xs!, target);
        }
    }

    operation MarkingOracleAsPhase(
        markingOracle : (Qubit[], Qubit) => Unit is Adj, 
        register : Qubit[]) : Unit is Adj
        {
            use target = Qubit();
            within {
                X(target);
                H(target);
            } apply {
                markingOracle(register, target);
            }
        }
}
