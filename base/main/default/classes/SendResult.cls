@NamespaceAccessible
public without sharing class SendResult {
    public final Boolean isSuccess {get; private set;}

    public SendResult(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }
}