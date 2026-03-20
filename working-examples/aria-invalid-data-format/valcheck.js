// Attach button click handler and set default date
document.addEventListener('DOMContentLoaded', function() {
	// Set default date to today
	const startDt = document.getElementById('startDt');
	if (startDt && startDt.value === '') {
		startDt.value = formatDate();
	}

	const loginBtn = document.getElementById('next_btn');
	if (loginBtn) {
		loginBtn.addEventListener('click', function(event) {
			errorAlert();
		});
	}
});

function errorAlert() {
	// Reset state: hide error message and clear field errors
	const errorMessage = document.getElementById("error-header");
	errorMessage.hidden = true;

	document.querySelectorAll('div.control div.errtext').forEach(div => div.remove());
	document.querySelectorAll('div.control input').forEach(input => {
		input.removeAttribute('aria-describedby');
		input.removeAttribute('aria-invalid');
		input.classList.remove('error');
	});

	// Field configuration with custom error messages
	// isRequired: true means we manually check for empty values
	const fields = [
		{ id: 'pin4', isRequired: true, emptyMsg: 'Error: PIN is required', errorMsg: 'Error: PIN must be exactly 4 digits' },
		{ id: 'email', isRequired: true, emptyMsg: 'Error: Email is required', errorMsg: 'Error: Invalid email address' },
		{ id: 'lname', isRequired: true, emptyMsg: 'Error: Last name is required', errorMsg: 'Error: Last name must be 2 or more letters' },
		{ id: 'startDt', isRequired: false, errorMsg: 'Error: Invalid date format' }
	];

	let hasErrors = false;

	fields.forEach((fieldConfig, index) => {
		const field = document.getElementById(fieldConfig.id);
		const value = field.value.trim();

		// For startDt: if empty, fill in today's date (not required)
		if (fieldConfig.id === 'startDt' && value === '') {
			field.value = formatDate();
			return; // Skip validation for this field
		}

		// Manual check for required fields
		if (fieldConfig.isRequired && value === '') {
			addFieldError(field, fieldConfig.emptyMsg);
			hasErrors = true;
			return;
		}

		// Check pattern validity using Constraint Validation API
		if (value !== '' && field.validity.patternMismatch) {
			addFieldError(field, fieldConfig.errorMsg);
			hasErrors = true;
			return;
		}

		// Check type validity (for email)
		if (value !== '' && field.validity.typeMismatch) {
			addFieldError(field, fieldConfig.errorMsg);
			hasErrors = true;
			return;
		}

		// Additional check for startDt: date must be in the future
		if (fieldConfig.id === 'startDt' && value !== '' && !dateLater(value)) {
			addFieldError(field, 'Error: Start date cannot be in the past');
			hasErrors = true;
		}
	});

	if (hasErrors) {
		errorMessage.hidden = false;
		errorMessage.textContent = 'Please fix the errors and retry';
		errorMessage.focus();
		return false;
	}
}

function addFieldError(field, message) {
	const errId = field.id + '-errormsg';
	const errDiv = document.createElement('div');
	errDiv.className = 'errtext';
	errDiv.id = errId;
	errDiv.textContent = message;

	field.parentNode.appendChild(errDiv);
	field.setAttribute('aria-describedby', errId);
	field.setAttribute('aria-invalid', 'true');
	field.classList.add('error');
}

function dateLater(dtStr) { // compares input date string with current date
const yy = parseInt(dtStr.substring(0, 4), 10);
const mm = parseInt(dtStr.substring(5, 7), 10) - 1; // months are 0-indexed
const dd = parseInt(dtStr.substring(8, 10), 10);
const inputDate = new Date(yy, mm, dd);
inputDate.setHours(0, 0, 0, 0);

const today = new Date();
today.setHours(0, 0, 0, 0);

// Returns true if date is today or in the future (valid)
// Returns false if date is before today (error)
return inputDate >= today;
}

function formatDate() {
const dt1 = new Date();
const mm = String(dt1.getMonth() + 1).padStart(2, '0');
const dd = String(dt1.getDate()).padStart(2, '0');
return dt1.getFullYear() + "-" + mm + "-" + dd;
}
