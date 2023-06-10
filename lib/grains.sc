FxGrains : FxBase {

    *new { 
        var ret = super.newCopyArgs(nil, \none, (
            transpose: 0,
            pos: 0.5,
            size: 0.25,
            density: 0.4,
            texture: 0.5,
            spread: 0.5,
            reverb: 0,
            feedback: 0,
            freeze: 0,
            mode: 0,
            lofi: 0,
            lfoPeriod: 1,
            lfoWidth: 0.5,
            randPeriod: 0.5,
            lfoTranspose: 0,
            lfoPos: 0,
            lfoSize: 0,
            lfoDensity: 0,
            lfoTexture: 0,
            randTranspose: 0,
            randPos: 0,
            randSize: 0,
            randDensity: 0,
            randTexture: 0,
            drywet: 1,
        ), nil, 1);
        ^ret;
    }

    *initClass {
        FxSetup.register(this.new);
    }

    internalDryWet {
        ^true;
    }

    subPath {
        ^"/fx_grains";
    }  

    symbol {
        ^\fxGrains;
    }

    addSynthdefs {
        SynthDef(\fxGrains, {|inBus, outBus|
            var input = In.ar(inBus, 2);
            var lfo = VarSaw.kr(\lfoPerod.kr(1).reciprocal, width: \lfoWidth.kr(0.5));
            var rand = LFNoise1.kr(\randPeriod.kr(0.5));
            Out.ar(
                outBus,
                MiClouds.ar(
                    input,
                    pit: \transpose.kr(0) + (
                        12 * ((\lfoTranspose.kr(0)*lfo) + (\randTranspose.kr(0)*rand))),
                    pos: (\pos.kr(0.5) + (
                        ((\lfoPos.kr(0)*lfo.unipolar) + (\randPos.kr(0)*rand.unipolar)))).clip(0, 1),
                    size: (\size.kr(0.25) + (
                        ((\lfoSize.kr(0)*lfo.unipolar) + (\randSize.kr(0)*rand.unipolar)))).clip(0, 1),
                    dens: (\density.kr(0.4) + (
                        ((\lfoDensity.kr(0)*lfo.unipolar) + (\randDensity.kr(0)*rand.unipolar)))).clip(0, 1),
                    tex: (\texture.kr(0.5) + (
                        ((\lfoTexture.kr(0)*lfo.unipolar) + (\randTexture.kr(0)*rand.unipolar)))).clip(0, 1),
                    drywet: \drywet.kr(1),
                    spread: \spread.kr(0.5),
                    rvb: \reverb.kr(0),
                    fb: \feedback.kr(0),
                    freeze: \freeze.kr(0),
                    mode: \mode.kr(0),
                    lofi: \lofi.kr(0),
                    //trig: \trig.tr(0)
                )
            );
        }).add;
    }

}