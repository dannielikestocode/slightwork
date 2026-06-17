/**
 * Demo class for interacting with in-memory Account data.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public inherited sharing class AccountsServiceDemo {
    /**
     * Properties
     */
    private final Map<Integer, AccountDTO> accountsList {get;set;}
    private Integer currentNumberOfAccounts {get;set;}

    /**
     * Default, no-arg constructor
     */
    public AccountsServiceDemo(Integer numberOfAccountsToCreate) {
        if (numberOfAccountsToCreate == null || numberOfAccountsToCreate < 1) {
            throw new IllegalArgumentException('Missing number of accounts to created');
        }
        this.accountsList = this.initializeDemoAccounts(numberOfAccountsToCreate);
        this.currentNumberOfAccounts = numberOfAccountsToCreate;
    }

    /**
     * Simulates the creation of an account 
     * 
     * @param accountName The name of the account to create
     * @return The Id of the created account
     */
    public Integer createAccount(String accountName) {
        if (String.isBlank(accountName)) {
            throw new IllegalArgumentException('Account Name must be provided');
        }
        this.currentNumberOfAccounts++;
        this.accountsList.put(this.currentNumberOfAccounts, new AccountDTO(this.currentNumberOfAccounts, accountName));
        return this.currentNumberOfAccounts;
    }

    /**
     * Returns an account by Id
     * 
     * @param accountId The Id of the account to retrieve
     * @return The retrieved account
     */
    public AccountDTO getAccountById(Integer accountId) {
        AccountDTO accountRecord = this.accountsList.get(accountId);
        if (accountRecord == null) {
            throw new QueryException('Account cannot be found for Id ' + accountId);
        }
        return accountRecord;
    }

    /**
     * Simulates updating an account (full or partial)
     * 
     * @param accountId The Id of the account to update
     * @param accountName The new name of the account
     */
    public void updateAccountById(Integer accountId, String accountName) {
        if (accountId == null) {
            throw new IllegalArgumentException('Account Id must be provided');
        }

        if (String.isBlank(accountName)) {
            throw new IllegalArgumentException('Account Name must be provided');
        }

        AccountDTO accountToUpdate = this.accountsList.get(accountId);
        if (accountToUpdate == null) {
            throw new QueryException('Account to update cannot be found for Id ' + accountId);
        }

        this.accountsList.put(accountId, new AccountDTO(accountId, accountName));
    }

    /**
     * Simulates the deletion of an account
     * 
     * @param accountId The Id of the account to delete
     */
    public void deleteAccountById(Integer accountId) {
        Integer startingNumberOfAccounts = this.accountsList.size();
        Object deletedAccount = this.accountsList.remove(accountId);
        if (deletedAccount == null) {
            throw new QueryException('Account to delete cannot be found for Id ' + accountId);
        }
    }

    /**
     * Creates collection of in-memory account records
     */
    private Map<Integer, AccountDTO> initializeDemoAccounts(Integer numberOfAccounts) {
        Map<Integer, AccountDTO> newAccounts = new Map<Integer, AccountDTO>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            newAccounts.put(i, new AccountDTO(i, 'Account ' + i));
        }
        return newAccounts;
    }

    /**
     * Inner class to represent a Data Transfer
     * Object (i.e., wrapper) for accounts
     */
    public class AccountDTO {
        /**
         * Properties
         */
        @AuraEnabled public final Integer accountId {get; private set;}
        @AuraEnabled public final String accountName {get; private set;}

        /**
         * Constructor with args
         * 
         * @param accountId The Id of an account
         * @param accountName The name of an account
         */
        public AccountDTO(Integer accountId, String accountName) {
            this.accountId = accountId;
            this.accountName = accountName;
        }
    }
}