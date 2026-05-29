package com.rayhan.erp.controller;

import com.rayhan.erp.dto.request.LoginRequest;
import com.rayhan.erp.dto.request.SignupRequest;
import com.rayhan.erp.dto.response.JwtResponse;
import com.rayhan.erp.dto.response.MessageResponse;
import com.rayhan.erp.model.ERole;
import com.rayhan.erp.model.Role;
import com.rayhan.erp.model.User;
import com.rayhan.erp.repository.RoleRepository;
import com.rayhan.erp.repository.UserRepository;
import com.rayhan.erp.security.jwt.JwtUtils;
import com.rayhan.erp.security.services.UserDetailsImpl;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired AuthenticationManager authenticationManager;
    @Autowired UserRepository userRepository;
    @Autowired RoleRepository roleRepository;
    @Autowired PasswordEncoder encoder;
    @Autowired JwtUtils jwtUtils;

    /**
     * POST /api/auth/signin
     * Connexion d'un utilisateur — retourne un token JWT
     */
    @PostMapping("/signin")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
            .map(item -> item.getAuthority())
            .collect(Collectors.toList());

        return ResponseEntity.ok(new JwtResponse(jwt,
            userDetails.getId(),
            userDetails.getUsername(),
            userDetails.getEmail(),
            userDetails.getFirstName(),
            userDetails.getLastName(),
            roles));
    }

    /**
     * POST /api/auth/signup
     * Inscription d'un nouvel utilisateur (réservé au PDG en production)
     */
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signUpRequest) {
        if (userRepository.existsByUsername(signUpRequest.getUsername())) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Erreur : Ce nom d'utilisateur est déjà pris."));
        }
        if (userRepository.existsByEmail(signUpRequest.getEmail())) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Erreur : Cet email est déjà utilisé."));
        }

        User user = new User(
            signUpRequest.getUsername(),
            signUpRequest.getEmail(),
            encoder.encode(signUpRequest.getPassword()),
            signUpRequest.getFirstName(),
            signUpRequest.getLastName());

        Set<String> strRoles = signUpRequest.getRoles();
        Set<Role> roles = new HashSet<>();

        if (strRoles == null || strRoles.isEmpty()) {
            Role magasinierRole = roleRepository.findByName(ERole.ROLE_MAGASINIER)
                .orElseThrow(() -> new RuntimeException("Rôle introuvable en base."));
            roles.add(magasinierRole);
        } else {
            strRoles.forEach(role -> {
                ERole eRole = switch (role.toLowerCase()) {
                    case "pdg" -> ERole.ROLE_PDG;
                    case "vente" -> ERole.ROLE_RESPONSABLE_VENTE;
                    case "achat" -> ERole.ROLE_RESPONSABLE_ACHAT;
                    case "production" -> ERole.ROLE_RESPONSABLE_PRODUCTION;
                    case "rh" -> ERole.ROLE_RH;
                    default -> ERole.ROLE_MAGASINIER;
                };
                Role foundRole = roleRepository.findByName(eRole)
                    .orElseThrow(() -> new RuntimeException("Rôle introuvable : " + role));
                roles.add(foundRole);
            });
        }

        user.setRoles(roles);
        userRepository.save(user);
        return ResponseEntity.ok(new MessageResponse("Utilisateur créé avec succès !"));
    }
}
