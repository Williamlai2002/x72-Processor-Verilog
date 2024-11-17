# x72-Processor-Verilog
The x72 Processor is a simple, custom-designed CPU architecture. This project explores foundational concepts in processor design, including the functionality and integration of key components such as the Arithmetic Logic Unit (ALU), registers, control units, and buses. The x72 features clear instruction encoding, operation decoding, and a streamlined datapath, providing an accessible framework for implementing and understanding processor architecture.

The processor that is designed in the project is shown in the image below:
<img width="756" alt="image" src="https://github.com/user-attachments/assets/8a5d3d4f-4308-4332-a4fa-e4e42efd8453">


# component functionality
The Arithmetic Logic Unit (ALU) performs arithmetic (e.g., addition, subtraction) and logical operations (e.g., AND, OR) essential to the processor’s functionality.

Registers are fast storage locations used for actively operated values, built as 16-bit D flip-flops. They include general-purpose registers for program use and special-purpose ones, like the instruction register, for managing execution.

The bus is a 16-bit communication channel connecting processor components, enabling data transfer through control signals and multiplexers.

The control unit manages instruction execution by decoding and sending control signals to activate components like registers and the ALU. For example, the signal R3in enables register R3 to store bus data.

A tick counter (a finite state machine) tracks the instruction execution stages, guiding the control unit on which signals to assert at each step.
