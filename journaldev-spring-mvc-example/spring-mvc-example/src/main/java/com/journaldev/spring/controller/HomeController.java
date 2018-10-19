package com.journaldev.spring.controller;

import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.beans.factory.annotation.*;

import com.journaldev.spring.model.User;

import java.net.URL;
import java.net.HttpURLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;

@Controller
public class HomeController {

	@Value("${APIGEE_PROXY_URL}")
	private String apigee_proxy_url;

	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		System.out.println("Home Page Requested, locale = " + locale);
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);

		String formattedDate = dateFormat.format(date);

		model.addAttribute("serverTime", formattedDate);

                try {
                        URL url = new URL(apigee_proxy_url);
                        HttpURLConnection con = (HttpURLConnection) url.openConnection();
                        con.setRequestMethod("GET");
                        int status = con.getResponseCode();
                        BufferedReader in = new BufferedReader(
                        new InputStreamReader(con.getInputStream()));
                        String inputLine;
                        StringBuffer content = new StringBuffer();
                        while ((inputLine = in.readLine()) != null) {
                            content.append(inputLine);
                        }
                        in.close();
                        String apigeeResponse = content.toString();
                        System.out.println(apigeeResponse);
                        model.addAttribute("apigeeResponse", apigeeResponse);
                } catch (Throwable t) {
                        System.out.println (t.toString());
                }

		return "home";
	}

	@RequestMapping(value = "/user", method = RequestMethod.POST)
	public String user(@Validated User user, Model model) {
		System.out.println("User Page Requested");
		model.addAttribute("userName", user.getUserName());
		return "user";
	}
}
