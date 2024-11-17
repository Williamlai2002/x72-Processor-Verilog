# x72-Processor-Verilog
The x72 Processor is a simple, custom-designed CPU architecture. This project explores foundational concepts in processor design, including the functionality and integration of key components such as the Arithmetic Logic Unit (ALU), registers, control units, and buses. The x72 features clear instruction encoding, operation decoding, and a streamlined datapath, providing an accessible framework for implementing and understanding processor architecture.

The processor that is designed in the project is shown in the image below:
<img width="756" alt="image" src="https://github.com/user-attachments/assets/8a5d3d4f-4308-4332-a4fa-e4e42efd8453">


# Component functionality
The Arithmetic Logic Unit (ALU) performs arithmetic (e.g., addition, subtraction) and logical operations (e.g., AND, OR) essential to the processor’s functionality.

Registers are fast storage locations used for actively operated values, built as 16-bit D flip-flops. They include general-purpose registers for program use and special-purpose ones, like the instruction register, for managing execution.

The bus is a 16-bit communication channel connecting processor components, enabling data transfer through control signals and multiplexers.

The control unit manages instruction execution by decoding and sending control signals to activate components like registers and the ALU. For example, the signal R3in enables register R3 to store bus data.

A tick counter (a finite state machine) tracks the instruction execution stages, guiding the control unit on which signals to assert at each step.


# Datapath overview
## DIN Wires

Positioned on the middle-left of the diagram.

## Arithmetic Logic Unit (ALU)

Located on the upper-right of the diagram.
Accepts two 16-bit data inputs and an ALUop control signal to determine the operation.
Uses:
A Register: Stores intermediate computation values.
G Register: Holds the result of ALU computations.
General Purpose (GP) Registers

## Eight 16-bit registers (R0 to R7) for data storage.
For simplicity, registers R1 to R6 are omitted from the diagram.
## Instruction Register (IR)

A 9-bit special-purpose register holding the current instruction.
## Central Data Bus

Implemented with a multiplexer featuring 10 inputs:
Value from the IR (current instruction).
Values from each GP register.
Output from the ALU.
The Bus Control signal selects which input is routed to the bus.
## Control Unit
Inputs:
Current instruction from the IR.
Tick FSM output.
Function:
Decodes inputs to generate control signals like ALUop, Rin, Gin, and Bus Control, coordinating operations across the datapath.

## Tick FSM

Ensures multi-cycle instruction execution by breaking each instruction into smaller steps, asserting appropriate control signals at each stage.
## Reset Signal

A synchronous signal that clears all register contents, including the IR, to initialize the processor state.


# Opcode
The most significant 3 bits of the 9-bit instruction represent the opcode.
Up to 8 instructions are supported, each defining a specific operation.

## Instruction types:
Type 1: Register-to-Register Operations
Move and manipulate data between two registers.
Format: Opcode + Register X (Rx) + Register Y (Ry).
Type 2: Immediate Value Operations
Introduce or manipulate data using immediate values.
Format: Opcode + Register X (Rx) + Immediate Value.

<img width="512" alt="image" src="https://github.com/user-attachments/assets/560ec8cb-3961-4623-b823-0ed3381aecf0">


## Tick by Tick Description of Each Instruction

## General Workflow
Each instruction progresses through multiple ticks:
Tick 1: Fetch instruction into the instruction register (IR) for decoding.
Subsequent ticks perform operations based on the instruction type.

## Instruction Breakdown
### disp Rx

Tick 2: Display the value in Rx on HEX displays.
Tick 3 & 4: Processor idles until ready for the next instruction.
### add Rx, Ry

Tick 2: Load Rx value into register A.
Tick 3: Add Ry value to A; store result in register G.
Tick 4: Write result from G back into Rx.
### addi Rx, Immi

Tick 2: Load immediate value into register A.
Tick 3: Add Rx value to A; store result in register G.
Tick 4: Write result from G back into Rx.
### sub Rx, Ry

Tick 2: Load Rx value into register A.
Tick 3: Subtract Ry value from A; store result in G.
Tick 4: Write result from G back into Rx.
### mul Rx, Ry

Tick 2: Load Rx value into register A.
Tick 3: Multiply Ry value with A; store result in G.
Tick 4: Write result from G back into Rx.

### ssi Rx (Shift and Store Immediate)

Tick 2: Load immediate value into register A.
Tick 3: Shift Rx by the immediate value; store result in G.
Tick 4: Write result from G back into Rx.
### movi Rx, Immi

Tick 2: Load immediate value directly into Rx.
Tick 3 & 4: Processor idles until ready for the next instruction.

