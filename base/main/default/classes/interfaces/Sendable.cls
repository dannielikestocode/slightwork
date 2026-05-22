/**
 * Classes that implement this interface are considered "Sendable",
 * meaning they they have the ability to send/deliver a message.
 */
@NamespaceAccessible
public interface Sendable {
    SendResult send();
}