---
title: "My own OS?"
date: 2026-03-28
description: "Not so long ago, I started writing my own operating system."
tags: ["osdev", "aosta"]
---

In fact, I started writing it back in february, but I spent a lot of time on theory. Plus, I took a long break to prepare for exams. In any case, I'll introduce you to Aosta. I haven't done much work yet, but I can already share what I've accomplished. This is supposed to be an x86_64-based. At this stage, it's hard to call it an operating system; I'm just finishing up the interrupts. I've been using Limine as bootloader, which I found to be a convenient option for configuration. I'll tell you about what's ready so far.

## 1st block: interrupts

- [x] CPU exception handlers
- [x] PIC
- [x] Hardware interrupt handlers
- [x] System timer
- [ ] Keyboard 

## 30th day of development

I'll tell you what I did last.

I've completed the basic exception handling system. When an interrupt occurs in the processor - an error, a keystroke, a timer, it must stop the current code, save the state, call the handler, and return back. To do this, you need a table where it should be indicated at which interrupt which function to call, IDT. Table of interrupt descriptors. This is an array of 256 records, each containing a handler address and parameters. The structure of a single record:

```c
struct IDTEntry {
    uint16_t offset_low;  
    uint16_t selector;  
    uint8_t ist;         
    uint8_t attributes;  
    uint16_t offset_mid;   
    uint32_t offset_high; 
    uint32_t zero;        
} __attribute__((packed));
```

Pointer to the IDT (what is passed to the processor via the lidt instruction):

```c
struct IDTPointer {
    uint16_t limit; 
    uint64_t base;
} __attribute__((packed));
```

You also need the handler registration function, idt_set_gate, which takes the 64-bit address of the handler, splits it into 3 parts, writes it to the IDT, sets the selector to the current CS (0x28), and then sets the attributes (0x8E = present, interrupt gate, ring 0).
idt_init() initializes the IDT, which zeros the table (all 256 entries), registers the handlers, fills in the idt_ptr (address and size of the tables), and loads it into the processor. Now the processor knows where to look for handlers.

I made an assembler handler, a table of pointers to ISRs, and a serial port for debugging. 

I had a problem that I couldn't solve for a long time: the IDT wouldn't load. It was mostly due to my carelessness: the selector in the IDT was 0x08, but the current CS was 0x28, causing a Triple Fault. Now I get the CS dynamically using mov %%cs. Additionally, I was passing incorrect flags somewhere. 

## What's next

Next, I'm working on the PIC 8259, but once I've mastered the basics, I'll start working on the modern APIC.

Maybe one day I'll go into more detail, I don't have that much time right now, haha. See you next time.