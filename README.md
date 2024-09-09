# `bio`

welcome to `bio`, lua Simulo scripting project

project is an ecosystem of creatures with:
- adaptive bodies
  - shapes, joints and bodies evolving
- limited resources (this will force organisms to seek food and thus be active)

it aims to be a very highlevel simulation of life. no cells, just creatures

```
@bio/bio;https://github.com/simulo-bio/bio.git
```

## penalties

a penalty refers to a loss in energy, applied to encourage being more efficient

for example using a joint takes energy, this can be considered an energy penalty applied for joint use

## body & joints

all joints are hinges. body is made up of nothing but capsules

ideally, wheels would be discouraged (in favor of legs) but unsure how to do this
  - penalty for short capsules?

body mutation types:
- Shape
  - every part of it is mutated randomly
  - color too, it would be very interesting to have them mutate to camouflage, like ground color
- Joint
- Shape Add
- Shape Remove
- Joint Add
- Joint Remove

head is a premade and unchanging capsule, with builtin sensors like raycast sight

## brain

brain is a list of nodes to run each step

turing complete system

just mutate the brain AST each time, changing either a param of a node, a node itself, or add/remove node, or change order of two random nodes

## sensors

sensors are fixed on head and unchanging, not evolving or mutating, just fixed forever to what we want to give em

here they are:
- raycast sight, with distance and normal
  - disabled when sleeping
- audio, along with exact position it came from, relative to head

in addition joint and bodypart position, linvel, angvel, angle, etc also provided along with what is touching something

all positions are relative though, this aims to prevent brain code that is designed for near 0,0 because then organisms would start to be insane when they move far away
as for angle, probably relative too, would allow them to work on round planets even after evolve for flat

## brain outputs

- audio, within a good range of sounds that wont hurt humano ears
  - max one audio per step, each of like, 1/60 duration
    - tiny resource penalty when you do it to discourage nonstop sound production for no reason
  - they pick volume too, theres a limit to how high they can go and higher penalty on louder sound
- sleep toggle, small penalty for enter sleep but then you have greatly reduced use of energy, but you cant use joints
  - sight disabled here, but audio kept
- joint motor speed and maxtorque
  - resource use is based not on what you provide but instead on the torque applied on the joint
    - this can lead to very creative use of motor speed and maxmotortorque

brain can also store and retrieve memories, its just a lua table

theres no short/longterm split, they manage it themselves, but theres penalty for larger memory, thus they should probably be efficient and delete useless stuff

## brain time penalty (BTP)

penalty is applied based on how long brain step took
so for example if it took a while Second to step it, insane unimaginable penalty, its like if it had a stroke, itll probably immediately die if it does that
so it needs to be efficient and optimal
penalty for brain size wouldnt need to exist, the time thing would work fine

however a consequence is this would remove determinism and creatures that thrived on one PC could perish easily in another
this can be addressed by disabling the brain time penalty when you want to interact with creatures on a random PC
when in this mode, mutations can also be disabled, so you just have a reliable consistent environment to interact with deterministic creatures
