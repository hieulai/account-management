module Constants

  # Association Types
  EMPLOYEE = "Employee"
  EMPLOYER = "Employer"
  VENDOR = "Vendor"
  CLIENT = "Client"
  BELONG = "Belong"
  HAS = "Has"

  ASSOCIATION_TYPES = [EMPLOYEE, EMPLOYER, VENDOR, CLIENT, BELONG, HAS]

  CONTACT = "Contact"
  SELF_EMPLOYED = "self_employed"
  COMPANY_CONTACT = "company_contact"

  # Roles
  COMPANY = "Company"
  PERSON = "Person"
  OWNER = "owner"
  ADMIN = "admin"
  ACCOUNTANT = "accountant"
  PAYROLL_MGR = "payroll_mgr"
  RECEIVABLES_MGR = "receivables_mgr"
  PAYABLES_MGR = "payables_mgr"
  PROJECT_MGR = "project_mgr"
  ESTIMATOR = "estimator"
  ACCOUNT_MGR = "account_mgr"

  PRIMARY_PHONE_TAGS = ["Main Phone", "Cell Phone", "Office Phone", "Home Phone", "Fax", "Pager"]
  SECONDARY_PHONE_TAGS = ["Secondary Phone", "Cell Phone ", "Office Phone", "Home Phone", "Fax", "Pager"]

  # Import/Export
  EMAIL = "email"
  COMPANY_NAME = "company_name"
  FIRST_NAME = "first_name"
  LAST_NAME = "last_name"
  ADDRESS_LINE_1 = "address_line_1"
  ADDRESS_LINE_2 = "address_line_2"
  CITY = "city"
  STATE = "state"
  ZIPCODE = "zipcode"
  PHONE = "phone"
  PHONE_TAG = "phone_tag"
  NOTES = "notes"
  EMPLOYMENT_STATUS = "employment_status"
  SELF_EMPLOYED_STATUS = "Self-Employed"
  RELATIONSHIPS = "relationships"
  COMPANY_CONTACT_HEADERS = [COMPANY_NAME, ADDRESS_LINE_1, ADDRESS_LINE_2, CITY, STATE, ZIPCODE, PHONE, PHONE_TAG, NOTES, RELATIONSHIPS]
  PERSON_CONTACT_HEADERS = [FIRST_NAME, LAST_NAME, EMAIL, ADDRESS_LINE_1, ADDRESS_LINE_2, CITY, STATE, ZIPCODE, PHONE, PHONE_TAG, EMPLOYMENT_STATUS, NOTES, RELATIONSHIPS]

  # Messages
  COMPANY_UNIQUENESS = "A company with this same name, phone number and address already exists. Duplicate companies are not allowed."
  PERSON_UNIQUENESS = "A person with this same name, phone number and address already exists. Duplicate people are not allowed."
end