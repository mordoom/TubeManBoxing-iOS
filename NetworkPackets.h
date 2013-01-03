/*
 *  NetworkPackets.h
 *  Tilemap
 *
 *  Created by Steffen Itterheim on 22.01.11.
 */

// TM16: note that all changes made to this send/receive example are prefixed with a // TM16: comment, to make the changes easier to find.

// Defines individual types of messages that can be sent over the network. One type per packet.
static const int MAX_LENGTH = 16;
typedef enum
{
    kPacketTypeCharacter,
	kPacketTypeDepleteHP,
    kPacketTypeAttack,
    kPacketTypeBackground,
} EPacketTypes;

typedef enum
{
    ButtonHighAttack = 1,
    ButtonLowAttack,
    ButtonDeflate,
    ButtonSpecial,
} EButtonPress;

// Note: EPacketType type; must always be the first entry of every Packet struct
// The receiver will first assume the received data to be of type SBasePacket, so it can identify the actual packet by type.
typedef struct
{
	EPacketTypes type;
} SBasePacket;

// the packet for transmitting the selected character for the player
typedef struct
{
	EPacketTypes type;
	char character[MAX_LENGTH];
} SCharacterPacket;

// the packet for transmitting damage to hp
typedef struct
{
	EPacketTypes type;
	int damage;
} SDepleteHPPacket;

// packet to transmit an attack
typedef struct
{
	EPacketTypes type;
	EButtonPress button;
} SAttackPacket;

//packet to sync the venue
typedef struct
{
    EPacketTypes type;
    int background;
}SBackgroundPacket;

// TODO for you: add more packets as needed. 

/*
 Note that Packets can contain several variables at once. So if you have a bunch of variables
 that you always send out together, put them in a single packet.
 
 But generally try to only send data when you really need to send it, to conserve bandwidth.
 For example, the position information in this example is only sent when the player position actually changed.
*/