# Cypher Handshake

**Category:** Network Forensics / Wireless Security  
**Difficulty:** Medium  

---

### Challenge Description
During a routine wireless perimeter audit, security sensors intercepted raw 802.11 IEEE radio frames from an unauthorized client communicating with an access point broadcasting the SSID **Cypher**.

Deep within the wireless capture lies an authentication exchange. Your mission is to analyze the wireless traffic, extract the authentication parameters, and recover the Pre-Shared Key (PSK).

### Provided Files
- `Cypher`: Raw Libpcap wireless network packet capture (`LINKTYPE_IEEE802_11`).

### Objective
1. Inspect the packet capture in a packet analysis tool (e.g. Wireshark).
2. Locate the 4-Way EAPOL Handshake frames exchanged between the client and access point.
3. Extract the network handshake parameters and recover the pre-shared key.

### Flag Format
Submit the recovered pre-shared key wrapped in the competition format:
```
BB{<cracked_key>}
```
*(Example: If the key was `dragon123`, the flag would be `BB{dragon123}`)*
