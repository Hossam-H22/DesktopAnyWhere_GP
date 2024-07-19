
import joi from "joi"

const dataMethods = ['body', 'query', 'params', 'headers']

export const generalFields = {
    id: joi.string().min(24).max(24).required(),
    userName: joi.string().alphanum().min(2).max(25).required().messages({
        'string.empty': 'Please fill in your UserName',
        'any.required': 'userName is required',
    }),
    email: joi.string().email({ minDomainSegments: 2, maxDomainSegments: 4, tlds: {allow: ['com', 'net', 'edu', 'eg']} }).required(),
    password : joi.string().pattern(new RegExp(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$/)).required(),
    cPassword: joi.string().required(),
    phone: joi.string().pattern(new RegExp(/^(002|\+2)?01[0125][0-9]{8}$/)),
    gender: joi.string().alphanum().valid('male', 'female').messages({
        "any.only": "please choose male of female",
    }),
}

const validation = (schema) => {
    return (req, res, next) => {

        const validatonArr = [];
        dataMethods.forEach(key => {
            if (schema[key]) {
                const validationResult = schema[key].validate(req[key], { abortEarly: false });
                if (validationResult.error) {
                    validatonArr.push(validationResult.error.details);
                }
            }
        });
        if (validatonArr.length > 0) {
            return res.json({ message: "Validation error", validatonArr });
        }
        else {
            next();
        }
    }
}

export default validation;